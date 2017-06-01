module gen.Generator;

import std.typecons;
import std.stdio;

import gen;
import semantics;
import syntax;

struct GeneratorCtx {
    OutputBuilder *builder;
    AlephTable table;
};

public auto generate(Tuple!(Program, AlephTable) tup, OutputStream stream)
{
    auto ctx = new GeneratorCtx(new OutputBuilder(stream), tup[1]);
    tup[0].route!GeneratorProvider(ctx);
    return ctx.builder;
}

template GeneratorProvider(alias Provider, Args...)
{
    auto visit(Return node, GeneratorCtx *ctx)
    {
        "before".writeln;
       // node.value.route!Provider(ctx);
        "after".writeln;
        return node;
    }

    auto visit(CallNode node, GeneratorCtx *ctx)
    {
        "call".writeln;
        /*
        with(ctx.builder){
            n.toCall.dispatch!GeneratorProvider(ctx);
            untabbed({
                printf("(");
                n.arguments.headLast!((x){ x.dispatch!GeneratorProvider(ctx); printf(", "); },
                                      (k){ x.dispatch!GeneratorProvider(ctx); });
                printf(")");
            });
        }
        */
        return node;
    }
};
