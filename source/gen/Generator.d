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
    Return visit(Return node, GeneratorCtx *ctx)
    {
        return node;
    }
};

template ReturnExpressionProvider(alias Provider, Args...)
{

};

