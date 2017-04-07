module semantics.Sugar;

import std.stdio;

import symbol.SymbolTable;
import symbol.Type;
import syntax.tree.visitors.ResultVisitor;
import std.range;

import util;

ASTNode desugar(ASTNode node)
{
    return new Sugar(node).visit(node);
}

/* A few things the Desugarer does: 
 * - Adds ReturnNode to functions without them (implied returns)
 * - transforms IfExpressions into IfStatements that 
 *   assign to a temporary */

class Sugar : ResultVisitor!ASTNode {
    this(ASTNode node){ super(node); }
override:
    void visitProgramNode(ProgramNode node)
    {
        import std.algorithm : each;
        node.children.each!(x => this.dispatch(x));
    }

    void visitReturnNode(ReturnNode node)
    {
        this.dispatch(node.value);
    }

    void visitProcDecl(ProcDeclNode node)
    {
        // Add a return node
        node.addReturn.then!(x =>
            // Add the implicit block node
            node.bodyNode.match(
                (BlockNode k){},
                (ExpressionNode k){ node.bodyNode = new BlockNode([node.bodyNode]); }
            ).then!(x => this.dispatch(x))
        );
    }

    // Unused functions
    void visitIntegerNode(IntegerNode node){}
    void visitIdentifierNode(IdentifierNode node){}
    void visitBlockNode(BlockNode node){}
}

private auto addReturn(ref ProcDeclNode pnode)
{
    pnode.bodyNode = pnode.bodyNode.match(
        (BlockNode n) =>
            n.children.use!(x =>
                x.back.match(
                    // No need to return a return node
                    (ReturnNode sub) => x,
                    // Return the last expression
                    (ExpressionNode sub) => x[0..$-1] ~ new ReturnNode(sub)
                )
            ).or(new ReturnNode(null)),
        (ExpressionNode node) => new ReturnNode(node)
    );
    return pnode;
}
