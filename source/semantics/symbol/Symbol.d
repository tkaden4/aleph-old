module semantics.symbol.Symbol;

import semantics.type.Type;

public interface Symbol {
    @property Type type();
    @property void type(Type t);
};
