module semantics.symbol.AliasSymbol;

import semantics.symbol.NamedSymbol;

public class AliasSymbol : NamedSymbol {
    this(string name, Type to)
    {
        super(name, to);
    }
};
