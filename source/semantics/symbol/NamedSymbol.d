module semantics.symbol.NamedSymbol;

import semantics.symbol.Symbol;
public import semantics.type.Type;

public class NamedSymbol : Symbol {
public:
    this(string _name, Type t)
    {
        this.name = _name;
        this.t = t;
    }

    override @property Type type()
    {
        return this.t;
    }

    override @property void type(Type ty)
    {
        this.t = ty;
    }
private:
    string name;
    Type t;
};
