module semantics.actions.Desugar;

import std.stdio;
import std.range;
import std.typecons;
import std.algorithm : each;
import std.meta;

import semantics.symbol;
import util;
import syntax;

public auto desugar(Tuple!(Program, AlephTable) node)
{
    return tuple(node[0].desugar, node[1]);
}


public Program desugar(Program node)
in {
    assert(node);
} body {
    return DesugarProvider!(DesugarProvider).visit(node);
}

template DesugarProvider(alias Provider, Args...){
    ProcDecl visit(ProcDecl node)
    {
        node.bodyNode = node.bodyNode.match(
            (Block node) => node,
            (Expression node) => new Block([node])
        ).then!(
            (x){
                x.children.back = x.children.back.match(
                    identity!Statement,
                    (Expression exp) => new Return(exp)
                );
            }
        );
        return DefaultProvider!(Provider, Args).visit(node);
    }

    T visit(T)(T t, Args args)
    {
        return DefaultProvider!(Provider, Args).visit(t, args);
    }
};
