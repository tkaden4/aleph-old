module semantics.actions.SymbolBuilderV2;

import syntax.visitors;
import semantics;

import std.stdio;


template SymbolBuilderProvider(alias Provider, Args...){
    auto visit(VarDeclNode node, AlephTable table)
    {
        "visiting vardecl".writeln;
        return node;
    }

    auto visit(ProcDeclNode node, AlephTable table)
    {
        "visiting procdecl".writeln;
        return node;
    }

    auto visit(ExternProcNode node, AlephTable table)
    {
        "visiting externproc".writeln;
        return node;
    }

    auto visit(LambdaNode node, AlephTable table)
    {
        "visiting lambdanode".writeln;
        return node;
    }

    T visit(T)(T t, Args args)
    {
        return DefaultProvider!(Provider, Args).visit(t, args);
    }
}

public auto buildSymbolsV2(ProgramNode node)
{
    import std.typecons;
    auto table = new AlephTable("Global Table");
    node = DefaultProvider!(SymbolBuilderProvider, AlephTable).visit(node, table);
    return tuple(node, table);
}
