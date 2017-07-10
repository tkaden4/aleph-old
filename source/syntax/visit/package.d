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

struct Eh {
    auto visit(N)(auto ref N n)
    {
        return n;
    }
}

auto visit(N, C)(auto ref scope N node, auto ref scope C visitor)
{
    const type = typeid(node);
    /* TODO get overloads and dispatch */
    return visitor.visit(node);
}

auto visit(alias C, N)(auto ref scope N node)
{
    return C.visit(node);
}

public {
    auto __test()
    {
        import std.stdio;
        auto prim = new CharPrimitive('8');
        auto node = new IfExpression(prim, prim, prim, null);
        node.visit(Eh());
    }
}
