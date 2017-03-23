module parse.symbol.SymbolTable;

import parse.symbol.Type;
import std.container;

struct Symbol {
    const string identifier;
    const Type type;
};

final class SymbolTable {
public:
    this()
    {
    
    }
private:
    Symbol[string] symbols;
    SList!SymbolTable children;
};
