module semantics.symbol.NamedSymbol;

import semantics.symbol.Symbol;
public import semantics.type.Type;

public class NamedSymbol : Symbol {
public:
    this(string _name, Type t)
    {
        this._name = _name;
        this.t = t;
    }

    @property string name()
    {
        return this._name;
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
    string _name;
    Type t;
};
