module semantics.symbol.VarSymbol;

import semantics.symbol.NamedSymbol;
import semantics.symbol.Symbol;
import semantics.SymbolTable;

import semantics.type.Type;

public class VarSymbol : NamedSymbol {
    this(string _name, Type _type, SymbolTable!Symbol _upper)
    {
        super(_name, _type);
        this.enclosing_scope = _upper;
    }
private:
    SymbolTable!Symbol enclosing_scope;
};
