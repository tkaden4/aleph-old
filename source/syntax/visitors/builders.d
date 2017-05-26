module syntax.visitors.builders;

public import syntax.tree;
public import util.meta;
import util;

import std.meta;
import std.typecons;
import std.traits;
import std.stdio;
import std.string;

template DefaultProvider(alias Provider,  Args...)
{
    alias P = Provider!(Provider, Args);

    ProgramNode visit(ProgramNode t, Args args)
    {
        foreach(ref x; t.children){
            x = P.visit(x, args);
        }
        return t;
    }

    DeclarationNode visit(DeclarationNode t, Args args)
    {
        return t.match(
            (StructDeclNode node) => P.visit(node, args),
            (VarDeclNode node)    => P.visit(node, args),
            (ProcDeclNode node)   => P.visit(node, args),
            (ExternProcNode node) => P.visit(node, args),
            (LambdaNode node)     => P.visit(node, args),
            (ExternImportNode node)   => P.visit(node, args),
            (){ throw new AlephException("Couldnt visit declaration %s".format(t)); }
        );
    }

    StatementNode visit(StatementNode node, Args args)
    {
        return node.match(
            (DeclarationNode node) => P.visit(node, args),
            (ReturnNode node)      => P.visit(node, args),
            (){ throw new AlephException("Could not visit statement %s".format(node)); }
        );
    }

    ExpressionNode visit(ExpressionNode t, Args args)
    {
        return t.match(
            (StatementNode node)   => P.visit(node, args),
            (BlockNode node)       => P.visit(node, args),
            (StringNode node)      => cast(ExpressionNode)P.visit(node, args),
            (CharNode node)        => cast(ExpressionNode)P.visit(node, args),
            (IntegerNode node)     => cast(ExpressionNode)P.visit(node, args),
            (IdentifierNode node)  => P.visit(node, args),
            (CallNode node)        => P.visit(node, args),
            (BinOpNode node)       => P.visit(node, args),
            (CastNode node)        => P.visit(node, args),
            (IfExpressionNode node)          => P.visit(node, args),
            (){ throw new AlephException("Could not visit expression %s".format(t)); }
        );
    }

    BinOpNode visit(BinOpNode node, Args args)
    {
        node.left = P.visit(node.left, args);
        node.right = P.visit(node.right, args);
        return node;
    }

    IfExpressionNode visit(IfExpressionNode node, Args args)
    {
        node.ifexp = P.visit(node.ifexp, args);
        node.thenexp = P.visit(node.thenexp, args);
        if(node.elseexp){
            node.elseexp = P.visit(node.elseexp, args);
        }
        return node;
    }

    CastNode visit(CastNode node, Args args)
    {
        node.node = P.visit(node.node, args);
        return node;
    }

    StructDeclNode visit(StructDeclNode node, Args args)
    {
        return node;
    }

    ExternImportNode visit(ExternImportNode node, Args args)
    {
        return node;
    }

    ReturnNode visit(ReturnNode node, Args args)
    {
        node.value = P.visit(node.value, args);
        return node;
    }

    CallNode visit(CallNode node, Args args)
    {
        node.toCall = P.visit(node.toCall, args);
        foreach(ref x; node.arguments){
            x = P.visit(x, args);
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
            x = P.visit(x, args);
        }
        return node;
    }

    VarDeclNode visit(VarDeclNode node, Args args)
    {
        node.initVal = P.visit(node.initVal, args);
        return node;
    }

    ExternProcNode visit(ExternProcNode node, Args args)
    {
        return node;
    }

    LambdaNode visit(LambdaNode node, Args args)
    {
        return node;
    }

    ProcDeclNode visit(ProcDeclNode node, Args args)
    {
        node.bodyNode = P.visit(node.bodyNode, args);
        return node;
    }
};

template ComposedProvider(U, Providers...)
{
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
template FunctionProvider(alias Provider, T, alias fun)
{
    template FunctionProvider(alias Prov, Args...){
        T visit(T t, Args args)
        {
            return fun!(Prov)(t, args);
        }
    }
};
