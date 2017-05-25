module semantics.actions.Desugar;

import std.stdio;
import std.range;
import std.typecons;
import std.algorithm : each;
import std.meta;

import semantics.symbol;
import util;
import syntax.visit.Visitor;
import syntax.tree;
import syntax.print;

public auto desugar(Tuple!(ProgramNode, AlephTable) node)
{
    return tuple(node[0].desugar, node[1]);
}


public ProgramNode desugar(ProgramNode node)
in {
    assert(node);
} body {
    new DesugarVisitor().dispatch(node);
    return node;
}

private final class DesugarVisitor : Visitor!void {
protected:
    override void visit(ref ProcDeclNode node)
    {
        node.bodyNode = node.bodyNode.match(
            (BlockNode node) => node,
            (ExpressionNode node) => new BlockNode([node])
        ).then!(
            (x){
                x.children.back = x.children.back.match(
                    identity!StatementNode,
                    (ExpressionNode exp) => new ReturnNode(exp)
                );
            }
        );
        super.visit(node);
    }

    override void visit(ref IfExpressionNode node)
    {

    }
};
