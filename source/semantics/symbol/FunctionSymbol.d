module semantics.symbol.FunctionSymbol;

import semantics.symbol.NamedSymbol;
import semantics.SymbolTable;
import semantics.symbol.Symbol;
import semantics.type.FunctionType;

import util.match;

public class FunctionSymbol : NamedSymbol {
    this(string _name, FunctionType ftype, SymbolTable!Symbol _bodyScope, bool external)
    {
        super(_name, ftype);
        this.bodyScope = _bodyScope;
        this.external = external;
    }

    invariant
    {
        assert(this.bodyScope);
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

    override string toString()
    {
        import std.string;
        return "FuncSym(%s)".format(this.type);
    }

    SymbolTable!Symbol bodyScope;
    bool external;
};
