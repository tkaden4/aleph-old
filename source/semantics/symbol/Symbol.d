module semantics.symbol.Symbol;

import semantics.type.Type;
import semantics.ctype.CType;

public alias Symbol = SymbolT!Type;
public alias CSymbol = SymbolT!CType;

public interface SymbolT(TypeType) {
    @property TypeType type();
    @property void type(TypeType t);
};
