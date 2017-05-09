module semantics.symbol.VarSymbol;

import semantics.symbol.NamedSymbol;
import semantics.symbol.AlephTable;
import semantics.type.Type;

public class VarSymbol : NamedSymbol {
    this(string _name, Type _type, AlephTable _upper)
    {
        super(_name, _type);
        this.enclosing_scope = _upper;
    }

    override string toString()
    {
        import std.string;
        return "VarSym(%s, %s)".format(this.name, this.type);
    }
private:
    AlephTable enclosing_scope;
};
