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
    tup[0].dispatch!GeneratorProvider(ctx);
    return ctx.builder;
}

template GeneratorProvider(alias Provider, Args...)
{
    auto visit(Return node, GeneratorCtx *ctx)
    {
        "before".writeln;
        node.value.dispatch!Provider(ctx);
        "after".writeln;
        return node;
    }

    /*
    auto visit(CallNode node, GeneratorCtx *ctx)
    {
        "call".writeln;
        with(ctx.builder){
            n.toCall.dispatch!GeneratorProvider(ctx);
            untabbed({
                printf("(");
                n.arguments.headLast!((x){ x.dispatch!GeneratorProvider(ctx); printf(", "); },
                                      (k){ x.dispatch!GeneratorProvider(ctx); });
                printf(")");
            });
        }
        return node;
    }
    */
};

template ReturnProvider(alias Provider, Args...)
{
        /*
    auto visit(IfExpression expression, GeneratorCtx *ctx)
    {
        "if(".write;
        //expression.ifexp.dispatch!GeneratorProvider(ctx);
        expression.ifexp.write;
        ")".writeln;
        expression.thenexp.dispatch!ReturnProvider(ctx);
        return expression;
    }

    /*
    auto visit(Block node, GeneratorCtx *ctx)
    {
        "what".writeln;
        node.children.headLast!(
                    x => x.dispatch!ReturnProvider(ctx),
                    x => x.dispatch!ReturnProvider(ctx)
                );
        return node;
    }
    */
};
