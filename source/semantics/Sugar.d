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
        foreach(x; node.children){
            x.visit(this);
        }
    }

    void visitReturnNode(ReturnNode node)
    {
        this.dispatch(node.value);
    }

    void visitProcDecl(ProcDeclNode node)
    {
        // Add a return node
        node.addReturn.bodyNode.match(
            (BlockNode k){},
            (ExpressionNode k){ node.bodyNode = new BlockNode([node.bodyNode]); }
        );
        this.dispatch(node.bodyNode);
    }

    // Unused functions
    void visitIntegerNode(IntegerNode node){}
    void visitIdentifierNode(IdentifierNode node){}
    void visitBlockNode(BlockNode node){}
}

auto addReturn(ref ProcDeclNode pnode)
{
    pnode.bodyNode = pnode.bodyNode.match(
        (BlockNode n) =>
            n.children.map!(x =>
                x.back.match(
                    // No need to return a return node
                    (ReturnNode sub) => x,
                    // Everything else
                    (ExpressionNode sub) => x[0..$-1] ~ new ReturnNode(sub)
                )
            ).or(new ReturnNode(null)),
        (ExpressionNode node) => new ReturnNode(node)
    );
    return pnode;
}
