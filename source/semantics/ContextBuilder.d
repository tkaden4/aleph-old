module semantics.ContextBuilder;

import syntax.visit.Visitor;
import semantics.symbol;

public auto buildContexts(Tup)(Tup t)
    if(is(isAggregateType!Tup))
{
    new ContextBuilder().dispatch(tup.expand);
    return tuple(t.expand);
}

private final class ContextBuilder : Visitor!(void, AlephTable) {

};
