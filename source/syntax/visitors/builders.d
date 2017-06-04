module syntax.visitors.builders;

public import syntax.tree;
public import util.meta;
import util;

import std.meta;
import std.typecons;
import std.traits;
import std.stdio;
import std.string;

public T route(alias V, T, Args...)(T t, Args args)
{
    static if(__traits(compiles, V!(V, Args).visit(t, args))){
        alias member = V!(V, Args);
        static if(!is(typeof(member.visit(t, args)) == T)){
            return DefaultProvider!(V, Args).visit(t, args);
        }else{
            return member.visit(t, args);
        }
    }else{
        return DefaultProvider!(V, Args).visit(t, args);
    }
}

template DefaultProvider(alias Provider, Args...)
{
    T defaultDispatch(T, Args...)(T t, Args args)
    {
        return route!Provider(t, args);
    }

    Program visit(Program t, Args args)
    {
        foreach(ref x; t.children){
            x = x.defaultDispatch(args);
        }
        return t;
    }

    Declaration visit(Declaration t, Args args)
    {
        return t.match(
            (VarDecl node)      => defaultDispatch(node, args),
            (StructDecl node)   => defaultDispatch(node, args),
            (ProcDecl node)     => defaultDispatch(node, args),
            (ExternProc node)   => defaultDispatch(node, args),
            (Lambda node)       => defaultDispatch(node, args),
            (ExternImport node) => defaultDispatch(node, args),
            (){ throw new AlephException("Couldnt visit declaration %s".format(t)); }
        );
    }

    Statement visit(Statement node, Args args)
    {
        return node.match(
            (Declaration n) => defaultDispatch(n, args),
            (Return n)      => defaultDispatch(n, args),
            (){ throw new AlephException("Could not visit statement %s".format(node)); }
        );
    }

    Expression visit(Expression e, Args args)
    {
        return e.match(
            (Statement node)        => defaultDispatch(node, args),
            (Block node)            => defaultDispatch(node, args),
            (StringPrimitive node)  => cast(Expression)defaultDispatch(node, args),
            (CharPrimitive node)    => cast(Expression)defaultDispatch(node, args),
            (IntPrimitive node)     => cast(Expression)defaultDispatch(node, args),
            (Identifier node)       => defaultDispatch(node, args),
            (Call node)             => defaultDispatch(node, args),
            (BinaryExpression node) => defaultDispatch(node, args),
            (Cast node)             => defaultDispatch(node, args),
            (IfExpression node)     => defaultDispatch(node, args),
            (Lambda node)           => defaultDispatch(node, args),
            (){ throw new AlephException("Could not visit expression %s".format(e)); }
        );
    }

    BinaryExpression visit(BinaryExpression node, Args args)
    {
        node.left = defaultDispatch(node.left, args);
        node.right = defaultDispatch(node.right, args);
        return node;
    }

    IfExpression visit(IfExpression node, Args args)
    {
        node.ifexp = defaultDispatch(node.ifexp, args);
        node.thenexp = defaultDispatch(node.thenexp, args);
        if(node.elseexp){
            node.elseexp = defaultDispatch(node.elseexp, args);
        }
        return node;
    }

    Cast visit(Cast node, Args args)
    {
        node.node = defaultDispatch(node.node, args);
        return node;
    }

    StructDecl visit(StructDecl node, Args args)
    {
        return node;
    }

    ExternImport visit(ExternImport node, Args args)
    {
        return node;
    }

    Return visit(Return node, Args args)
    {
        node.value = defaultDispatch(node.value, args);
        return node;
    }

    Call visit(Call node, Args args)
    {
        node.toCall = defaultDispatch(node.toCall, args);
        foreach(ref x; node.arguments){
            x = defaultDispatch(x, args);
        }
        return node;
    }

    Identifier visit(Identifier node, Args args)
    {
        return node;
    }

    IntPrimitive visit(IntPrimitive node, Args args)
    {
        return node;
    }

    CharPrimitive visit(CharPrimitive node, Args args)
    {
        return node;
    }

    StringPrimitive visit(StringPrimitive node, Args args)
    {
        return node;
    }

    Block visit(Block node, Args args)
    {
        foreach(ref x; node.children){
            x = defaultDispatch(x, args);
        }
        return node;
    }

    VarDecl visit(VarDecl node, Args args)
    {
        node.initVal = defaultDispatch(node.initVal, args);
        return node;
    }

    ExternProc visit(ExternProc node, Args args)
    {
        return node;
    }

    Lambda visit(Lambda node, Args args)
    {
        node.bodyNode = defaultDispatch(node.bodyNode, args);
        return node;
    }

    ProcDecl visit(ProcDecl node, Args args) {
        node.bodyNode = defaultDispatch(node.bodyNode, args);
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
