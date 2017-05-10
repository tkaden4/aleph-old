module semantics.Desugar;

import std.stdio;
import std.range;
import std.typecons;
import std.algorithm : each;

import semantics.symbol;
import util;
import syntax.visit.Visitor;
import syntax.tree;

public auto desugar(Tuple!(ProgramNode, AlephTable) node)
{
    return tuple(node[0].desugar, node[1]);
}

public ProgramNode desugar(ProgramNode node)
{
    new DesugarVisitor().dispatch(node);
    return node;
}

/* A few things the Desugarer does: 
 * - Adds ReturnNode to functions without them (implied returns)
 * - transforms IfExpressions into IfStatements that 
 *   assign to a temporary */


/* TODO make pure functions */
private class DesugarVisitor : Visitor!void {
protected:
    override void visit(ref ProcDeclNode node)
    {
        // Add a return node
        node.bodyNode = node.addReturn.use!(
            x => node.bodyNode.match(
                     (BlockNode block) => block,
                     (ExpressionNode sub) => new BlockNode([sub])
                 )
        ).then!(x => super.visit(x));
    }
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
