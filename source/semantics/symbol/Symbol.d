module semantics.symbol.Symbol;

import semantics.type.Type;

alias Symbol = SymbolT!Type;

public interface SymbolT(TypeType) {
    @property TypeType type();
    @property void type(TypeType t);
};
