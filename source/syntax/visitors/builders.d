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

    Program visit(Program t, Args args)
    {
        foreach(ref x; t.children){
            x = P.visit(x, args);
        }
        return t;
    }

    Declaration visit(Declaration t, Args args)
    {
        return t.match(
            (VarDecl node)      => P.visit(node, args),
            (StructDecl node)   => P.visit(node, args),
            (ProcDecl node)     => P.visit(node, args),
            (ExternProc node)   => P.visit(node, args),
            (Lambda node)       => P.visit(node, args),
            (ExternImport node) => P.visit(node, args),
            (){ throw new AlephException("Couldnt visit declaration %s".format(t)); }
        );
    }

    Statement visit(Statement node, Args args)
    {
        return node.match(
            (Declaration n) => P.visit(n, args),
            (Return n)      => P.visit(n, args),
            (){ throw new AlephException("Could not visit statement %s".format(node)); }
        );
    }

    Expression visit(Expression e, Args args)
    {
        return e.match(
            (Statement node)        => P.visit(node, args),
            (Block node)            => P.visit(node, args),
            (StringPrimitive node)  => cast(Expression)P.visit(node, args),
            (CharPrimitive node)    => cast(Expression)P.visit(node, args),
            (IntPrimitive node)     => cast(Expression)P.visit(node, args),
            (Identifier node)       => P.visit(node, args),
            (Call node)             => P.visit(node, args),
            (BinaryExpression node) => P.visit(node, args),
            (Cast node)             => P.visit(node, args),
            (IfExpression node)     => P.visit(node, args),
            (Lambda node)           => P.visit(node, args),
            (){ throw new AlephException("Could not visit expression %s".format(e)); }
        );
    }

    auto visit(BinaryExpression node, Args args)
    {
        node.left = P.visit(node.left, args);
        node.right = P.visit(node.right, args);
        return node;
    }

    auto visit(IfExpression node, Args args)
    {
        node.ifexp = P.visit(node.ifexp, args);
        node.thenexp = P.visit(node.thenexp, args);
        if(node.elseexp){
            node.elseexp = P.visit(node.elseexp, args);
        }
        return node;
    }

    auto visit(Cast node, Args args)
    {
        node.node = P.visit(node.node, args);
        return node;
    }

    auto visit(StructDecl node, Args args)
    {
        return node;
    }

    auto visit(ExternImport node, Args args)
    {
        return node;
    }

    auto visit(Return node, Args args)
    {
        node.value = P.visit(node.value, args);
        return node;
    }

    auto visit(Call node, Args args)
    {
        node.toCall = P.visit(node.toCall, args);
        foreach(ref x; node.arguments){
            x = P.visit(x, args);
        }
        return node;
    }

    auto visit(Identifier node, Args args)
    {
        return node;
    }

    auto visit(IntPrimitive node, Args args)
    {
        return node;
    }

    auto visit(CharPrimitive node, Args args)
    {
        return node;
    }

    auto visit(StringPrimitive node, Args args)
    {
        return node;
    }

    auto visit(Block node, Args args)
    {
        foreach(ref x; node.children){
            x = P.visit(x, args);
        }
        return node;
    }

    auto visit(VarDecl node, Args args)
    {
        node.initVal = P.visit(node.initVal, args);
        return node;
    }

    auto visit(ExternProc node, Args args)
    {
        return node;
    }

    auto visit(Lambda node, Args args)
    {
        node.bodyNode = P.visit(node.bodyNode, args);
        return node;
    }

    auto visit(ProcDecl node, Args args) {
        node.bodyNode = P.visit(node.bodyNode, args);
        return node;
    }

    T visit(T)(T t, Args arg)
    {
        static assert(true, "You failed");
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
