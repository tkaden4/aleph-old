module semantics.actions.ContextBuilder;

import syntax.visit.Visitor;
import semantics.symbol;
import std.traits;
import std.typecons;

public auto buildContexts(Tup)(Tup tup)
{
    new ContextBuilder().dispatch(tup.expand);
    return tuple(tup.expand);
}

struct ProgramContext {
};

private final class ContextBuilder : Visitor!(void, AlephTable) {

};
