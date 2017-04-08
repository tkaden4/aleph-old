module semantics.symbol.Symbol;

import semantics.symbol.Type;
import semantics.symbol.SymbolTable;

public class Symbol {
    this(string name, Type type, SymbolTable parent)
    {
        this.name = name;
        this.type = type;
        this.parentTable = parent;
    }

    override string toString() const
    {
        import std.string;
        return "Symbol(%s, %s)".format(this.name, this.type);
    }
public:
    string name;
    Type type;
    SymbolTable parentTable;
};
