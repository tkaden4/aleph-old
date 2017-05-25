module syntax.visitors;

public import syntax.tree;
public import util.meta;
import util;

import std.meta;
import std.typecons;
import std.traits;
import std.stdio;

/* default visitation rules and providers.
   all they do is visit the nodes and their
   children using provider passed to them */

template DefaultProvider(alias Provider, T: ExpressionNode) {
    public T visit(T t)
    {
        "visiting expression %s".writefln(t);
        return t;
    }
};

template DefaultProvider(alias Provider, T: DeclarationNode) {
    public T visit(T t)
    {
        import std.string;
        return t.match(
            (VarDeclNode node)    => Provider!(Provider, VarDeclNode).visit(node),
            (ProcDeclNode node)   => Provider!(Provider, ProcDeclNode).visit(node),
            (ExternProcNode node) => Provider!(Provider, ExternProcNode).visit(node),
            (LambdaNode node)     => Provider!(Provider, LambdaNode).visit(node),
            (){ throw new AlephException("Couldnt visit declaration %s".format(t)); }
        );
    }
};

template DefaultProvider(alias Provider, T: ProgramNode) {
    public T visit(T t)
    {
        "visiting program".writeln;
        foreach(ref x; t.children){
            x = Provider!(Provider, DeclarationNode).visit(x);
        }
        return t;
    }
};

/*
template ProviderReturn(alias Provider, T) {
    alias ProviderReturn = ReturnType!(Provider!(T).visit);
};

// create one provider from many different,
// offering the result as a tuple of all results
template MultiProvider(alias Provider, T, Providers...) {
    private alias Applied = Partial!(ProviderReturn, 1, T);
    private alias ProviderReturns = staticMap!(Applied, Providers);

    template MultiProvider(T){
        auto visit(T t)
        {
            auto tup = tuple!(ProviderReturns);
            foreach(i, x; Providers){
                tup[i] = x!(Provider, T).visit(t);
            }
            return tup;
        }
    };
};

// create a provider from a a function
template FunctionProvider(alias Provider, alias fun) {
    template FunctionProvider(alias Prov, T){
        public T visit(T t)
        {
            return fun!(Prov)(t);
        }
    }
};
*/
