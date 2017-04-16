module semantics.symbol.VarSymbol;

import semantics.symbol.NamedSymbol;
import semantics.symbol.SymbolTable;

import semantics.type.Type;

public class VarSymbol : NamedSymbol {
    this(string _name, Type _type, SymbolTable _upper)
    {
        super(_name, _type);
        this.enclosing_scope = _upper;
    }
private:
    SymbolTable enclosing_scope;
};
