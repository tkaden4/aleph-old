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
    return node.visit(Desugar());
}

struct Desugar {
    auto visit(Program prog)
    {
        return prog;
    }

    auto visit(ProcDecl node)
    {
        node.bodyNode = node.bodyNode.match(
            identity!Block,
            (Expression node) => new Block([node])
        ).then!(
            (x){
                if(x.children){
                    x.children.back = x.children.back.match(
                        identity!Statement,
                        (Expression exp) => new Return(exp)
                    );
                }
            }
        );
        //node.visit(Default(this));
        return node;
    }
};
