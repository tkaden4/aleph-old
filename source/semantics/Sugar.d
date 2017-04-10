module semantics.Sugar;

import std.stdio;

import syntax.tree.visitors.ASTVisitor;
import semantics.symbol.SymbolTable;
import std.range;

import util;

public ASTNode desugar(ProgramNode node)
{
    return new Sugar(node).apply(node);
}

/* A few things the Desugarer does: 
 * - Adds ReturnNode to functions without them (implied returns)
 * - transforms IfExpressions into IfStatements that 
 *   assign to a temporary */

private class Sugar : ASTVisitor {
public:
    ProgramNode result;
    this(ProgramNode node){ this.result = node; }
    auto apply(ASTNode node)
    {
        this.dispatch(node);
        return this.result;
    }
override:
    void visit(ProgramNode node)
    {
        import std.algorithm : each;
        node.children.each!(x => this.dispatch(x));
    }

    void visit(ReturnNode node)
    {
        this.dispatch(node.value);
    }

    void visit(ProcDeclNode node)
    {
        // Add a return node
        node.bodyNode = node.addReturn.use!(
            x => node.bodyNode.match(
                     (BlockNode block) => block,
                     (ExpressionNode sub) => new BlockNode([sub])
                 )
        ).then!(x => this.dispatch(x));
    }

    // Unused functions
    void visit(IntegerNode node){}
    void visit(IdentifierNode node){}
    void visit(BlockNode node){}
}

private auto addReturn(ProcDeclNode pnode)
{
    pnode.bodyNode = pnode.bodyNode.use!(
        x => x.match(
            (ReturnNode n) => n,
            (BlockNode n) =>
                n.children.use!(x =>
                    x.back.match(
                        // No need to return a return node
                        (ReturnNode sub) => sub,
                        // Return the last expression
                        (ExpressionNode sub) => new ReturnNode(sub)
                    )
                    // If there is no back
                    .or(new ReturnNode(null))
                    .use!(
                        // append the new node to then end of the body
                        end => n.children[0..$-1] ~ end
                    )
                ).use!(x => cast(ExpressionNode)new BlockNode(x)),
            (ExpressionNode node) => cast(ExpressionNode)new ReturnNode(node)
        )
    );
    return pnode;
}
