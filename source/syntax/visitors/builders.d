module syntax.visitors.builders;

public import syntax.tree;
public import util.meta;
import util;

import std.meta;
import std.typecons;
import std.traits;
import std.stdio;
import std.string;

template DefaultProvider(alias Provider,  Args...) {
    ProgramNode visit(ProgramNode t, Args args)
    {
        foreach(ref x; t.children){
            x = Provider!(Provider, Args).visit(x, args);
        }
        return t;
    }

    DeclarationNode visit(DeclarationNode t, Args args)
    {
        return t.match(
            (VarDeclNode node)    => Provider!(Provider, Args).visit(node, args),
            (ProcDeclNode node)   => Provider!(Provider, Args).visit(node, args),
            (ExternProcNode node) => Provider!(Provider, Args).visit(node, args),
            (LambdaNode node)     => Provider!(Provider, Args).visit(node, args),
            (){ throw new AlephException("Couldnt visit declaration %s".format(t)); }
        );
    }

    ExpressionNode visit(ExpressionNode t, Args args)
    {
        return t.match(
            (DeclarationNode node) => node.visit(args),
            (StatementNode node)   => node.visit(args),
            (BlockNode node)       => node.visit(args),
            (StringNode node)      => cast(ExpressionNode)node.visit(args),
            (CharNode node)        => cast(ExpressionNode)node.visit(args),
            (IntegerNode node)     => cast(ExpressionNode)node.visit(args),
            (IdentifierNode node)  => node.visit(args),
            (CallNode node)        => node.visit(args),
            (){ throw new AlephException("Could not visit expression %s".format(t)); }
        );
    }

    CallNode visit(CallNode node, Args args)
    {
        node.toCall = node.toCall.visit(args);
        foreach(ref x; node.arguments){
            x = x.visit(args);
        }
        return node;
    }

    IdentifierNode visit(IdentifierNode node, Args args)
    {
        return node;
    }

    IntegerNode visit(IntegerNode node, Args args)
    {
        return node;
    }

    CharNode visit(CharNode node, Args args)
    {
        return node;
    }

    StringNode visit(StringNode node, Args args)
    {
        return node;
    }

    BlockNode visit(BlockNode node, Args args)
    {
        foreach(ref x; node.children){
            x = x.visit(args);
        }
        return node;
    }

    T visit(T)(T t, Args args)
    {
        static assert(false, "You must provide a visitor for %s".format(T.stringof));
    }
};

template ComposedProvider(U, Providers...){
    /* the new provider */
    template ComposedProvider(alias Provider, Args...){
        /* the actual visitor function */
        U visit(U u, Args args)
        {
            foreach(x; newProviders){
                u = x!(Provider, Args).visit(u, args);
            }
            return u;
        }
    };
};

/*
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
*/

// create a provider from a a function
template FunctionProvider(alias Provider, T, alias fun) {
    template FunctionProvider(alias Prov, Args...){
        T visit(T t, Args args)
        {
            return fun!(Prov)(t, args);
        }
    }
};
