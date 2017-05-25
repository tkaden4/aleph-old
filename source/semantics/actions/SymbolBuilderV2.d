module semantics.actions.SymbolBuilderV2;

import syntax.visitors;

import std.stdio;

template SymbolBuilderProvider(alias Provider, T: VarDeclNode) {
    public T visit(T t)
    {
        "visiting VarDecl".writeln;
        return t;
    }
};

template SymbolBuilderProvider(alias Provider, T: ProcDeclNode) {
    public T visit(T t)
    {
        "visiting ProcDecl".writeln;
        t.bodyNode = Provider!(Provider, typeof(t.bodyNode)).visit(t.bodyNode);
        return t;
    }
};

template SymbolBuilderProvider(alias Provider, T: ExternProcNode) {
    public T visit(T t)
    {
        "visitin extern proc".writeln;
        return t;
    }
};

template SymbolBuilderProvider(alias Provider, T: LambdaNode) {
    public T visit(T t)
    {
        "visitin lambda node".writeln;
        return t;
    }
};

template SymbolBuilderProvider(alias Provider, T) {
    alias SymbolBuilderProvider = DefaultProvider!(Provider, T);
};

public alias SymbolBuilderV2 = DefaultProvider!(SymbolBuilderProvider, ProgramNode);
