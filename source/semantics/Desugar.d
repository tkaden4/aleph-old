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
in {
    assert(node);
} body {
    new DesugarVisitor().dispatch(node, cast(VarDeclNode)null);
    return node;
}

/* TODO make pure functions */
private class DesugarVisitor : Visitor!(void, VarDeclNode) {
protected:
    override void visit(ref ProcDeclNode node, VarDeclNode res)
    {
        node.bodyNode = node.bodyNode.match(
            (BlockNode node) => node,
            (ExpressionNode node) => new BlockNode([node])
        );
        auto x = (cast(BlockNode)node.bodyNode).children;
        x.back.match(
            (StatementNode _) => _,
            (ExpressionNode exp) => x.back = new ReturnNode(exp)
        );
        super.visit(node, res);
    }

    override void visit(ref IfExpressionNode node, VarDeclNode res)
    {
    
    }
}
