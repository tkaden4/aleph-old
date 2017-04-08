module semantics.symbol.SymbolTable;

public import semantics.symbol.Type;
public import semantics.symbol.Symbol;

import std.container;
import std.typecons;
import std.string;

final class SymbolTable {
public:
    this(SymbolTable parent = null)
    {
        this.parent = parent;
    }

    Nullable!(Symbol) opIndex(string id)
    {
        auto sym = id in this.symbols;
        if(this.parent){
            auto tmp = parent[id];
            if(!tmp.isNull){
                sym = sym ? sym : &tmp.get();
            }
        }
        if(sym){
            return nullable(*sym);
        }
        return Nullable!(Symbol).init;
    }

    Symbol insert(string id, Symbol s)
    {
        this.symbols[id] = s;
        return this.symbols[id];
    }


    SymbolTable enterScope()
    {
        this.children.insertFront(new SymbolTable(this));
        return this.children.front;
    }

    SymbolTable leaveScope()
    {
        return this.parent;
    }

    override string toString()
    {
        return "SymbolTable(%s)".format(this.symbols.length);
    }
private:
    Symbol[string] symbols;
    SymbolTable parent;
    SList!SymbolTable children;
};
