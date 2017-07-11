module syntax.visit;

import std.meta;
import std.traits;
import util.meta;
public import syntax;

/*
template staticMatch(Type, Args...)
{
    static assert(Args.length, "must have more than one branch");
    static if(Args.length > 1){
        alias Current = Args[0];
        static if(is(Type == Parameters!Current[0])){
            alias staticMatch = Current;
        }else{
            alias staticMatch = staticMatch!(Type, Args[1..$]);
        }
    }else{
        alias Current = Args[0];
        alias Param = Parameters!Current[0];
        enum str = Param.stringof;
        static assert(is(Type == Param), "couldn't match on " ~ str);
        alias staticMatch = Current;
    }
};

alias ChildVisitor =
    PartialApp!(staticMatch, 1,
                    (ProcDecl x) => x,
                );
*/

/* visits a node based on a condition */
struct ConditionVisitor(alias condition, alias then, alias otherwise) {
    static auto opCall(N)(auto ref N node)
    {
        if(condition(node)){
            return then(node);
        }else{
            return otherwise(node);
        }
    }
};

/* TODO unify both visitors */

auto visit(N, C)(auto ref scope N node, auto ref scope C visitor)
{
    const toVisitType = typeid(node);
    /* get all overloads */
    alias visitMethods = typeof(__traits(getOverloads, C, "visit"));
    foreach(x; visitMethods){
        alias current = Parameters!x[0];
        if(toVisitType == typeid(current)){
            return cast(N)visitor.visit(cast(current)node);
        }
    }
    static if(__traits(compiles, "return cast(N)visitor.visit(node);")){
        return cast(N)visitor.visit(node);
    }else{
        import std.string;
        throw new Exception("Unable to visit %s".format(node));
    }
}

/+
auto visit(alias C, N)(auto ref scope N node)
{
    const toVisitType = typeid(node);
    /* get all overloads */
    alias visitMethods = typeof(__traits(getOverloads, C, "visit"));
    foreach(x; visitMethods){
        alias current = Parameters!x[0];
        pragma(msg, current);
        if(toVisitType == typeid(current)){
            return visitor.visit(cast(current)node);
        }
    }
    if(__traits(compiles, "return visitor.visit(node);")){
        return C.visit(node);
    }else{
        import std.string;
        throw new Exception("Unable to visit %s".format(node));
    }
}
+/
