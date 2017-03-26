module symbol.SymbolTable;

import symbol.Type;

import std.container;
import std.typecons;

public struct Symbol {
    string identifier;
    Type type;
};

final class SymbolTable {
public:
    this(SymbolTable parent = null)
    {
        this.parent = parent;
    }

    Nullable!(Symbol) lookup(string id)
    {
        auto sym = id in this.symbols;
        sym = sym ? sym : &parent.lookup(id).get();
        if(sym){
            return nullable(*sym);
        }
        return Nullable!(Symbol).init;
    }

    void insert(string id, Symbol s)
    {
        this.symbols[id] = s;
    }
private:
    Symbol[string] symbols;
    SymbolTable parent;
    //SList!SymbolTable children;
};
