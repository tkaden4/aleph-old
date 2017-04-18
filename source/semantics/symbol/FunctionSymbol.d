module semantics.symbol.FunctionSymbol;

import semantics.symbol.NamedSymbol;
import semantics.SymbolTable;
import semantics.symbol.Symbol;
import semantics.type.FunctionType;

import util.match;

public class FunctionSymbol : NamedSymbol {
    this(string _name, FunctionType ftype, SymbolTable!Symbol bodyScope)
    {
        super(_name, ftype);
    }

    override @property void type(Type t)
    {
        t.match(
            (FunctionType t) => super.type = t,
            (Type t){ throw new Exception("Cannot assign non-function type"); }
        );
    }

    override @property Type type()
    {
        return super.type;
    }
};
