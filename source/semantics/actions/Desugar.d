module semantics.actions.Desugar;

import std.stdio;
import std.range;
import std.typecons;
import std.algorithm : each;

import semantics.symbol;
import util;
import syntax.visit.Visitor;
import syntax.tree;
import syntax.print;

public auto desugar(Tuple!(ProgramNode, AlephTable) node)
{
    return tuple(node[0].desugar, node[1]);
}

import util.meta;
import std.meta;

public ProgramNode desugar(ProgramNode node)
in {
    assert(node);
} body {
    new DesugarVisitor().dispatch(node);
    return node;
}

private class DesugarVisitor : Visitor!void {
protected:
    override void visit(ref ProcDeclNode node)
    {
        node.bodyNode = node.bodyNode.match(
            (BlockNode node) => node,
            (ExpressionNode node) => new BlockNode([node])
        );
        auto x = (cast(BlockNode)node.bodyNode).children;
        x.back = x.back.match(
            emptyFunc!StatementNode,
            (ExpressionNode exp) => new ReturnNode(exp)
        );
        super.visit(node);
    }
};
