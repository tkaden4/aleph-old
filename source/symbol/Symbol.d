module symbol.Symbol;

import symbol.Type;
import symbol.SymbolTable;

public class Symbol {
    this(string name, Type type, SymbolTable table)
    {
        this.name = name;
        this.type = type;
        this.table = table;
    }

    override string toString() const
    {
        import std.string;
        return "Symbol(%s, %s)".format(this.name, this.type);
    }
public:
    const(string) name;
    Type type;
    SymbolTable table;
};
