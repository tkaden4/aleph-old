module semantics.actions.TypeChecker;

import semantics;
import syntax;
import util;

import std.typecons;
import std.range;
import std.algorithm;
import std.string;
import std.stdio;

public auto checkTypes(Tuple!(Program, AlephTable) t)
{
    return alephErrorScope("type checker", {
        t[0] = TypeCheckProvider!(TypeCheckProvider).visit(t[0]);
        return t;
    });
}

private class AnyType : Type {
    override bool canCast(Type other)
    {
        return true;
    }

    override string toString() pure
    {
        return "AnyType()";
    }
};

private void checkCast(Type a, Type b, string extra="")
{
    a.canCast(b).err(new AlephException("couldn't cast %s to %s, %s".format(a, b, extra)));
}

template TypeCheckProvider(alias Provider, Args...) {
    ProcDecl visit(ProcDecl node)
    {
        node = DefaultProvider!(Provider).visit(node);
        node.returnType.checkCast(node.bodyNode.resultType, "in function \n%s".format(node.toPretty));
        return node;
    }

    VarDecl visit(VarDecl node)
    {
        node = DefaultProvider!(Provider).visit(node);
        node.type.checkCast(node.initVal.resultType, "in variable \n%s".format(node.toPretty(true)));
        return node;
    }

    Call visit(Call node)
    {
        auto funtype = node.toCall.resultType.match(
            (FunctionType f) => f,
            (){ throw new AlephException("could not call non-function"); }
        );

        auto parameters = funtype.parameterTypes;
        auto argumentTypes = node.arguments.map!(x => x.resultType);

        if(funtype.isVararg){
            for(size_t i = 0; i < argumentTypes.length - parameters.length; ++i){
                parameters ~= new AnyType;
            }
        }

        err(parameters.length == argumentTypes.length,
            new AlephException("Mismatched number of arguments in \n\t%s".format(node.toPretty)));

        /* get tuples of parameters */
        auto zipped = parameters.zip(node.arguments.map!(x => x.resultType)).array;
        foreach(a; zipped){
            checkCast(a[0], a[1]);
        }
        return node;
    }

    T visit(T)(T t)
    {
        return DefaultProvider!(Provider).visit(t);
    }
};
