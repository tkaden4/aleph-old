module symbol.SymbolTable;

import symbol.Type;

import std.container;
import std.typecons;
import std.string;

public struct Symbol {
    string identifier;
    Type type;

    string toString() const
    {
        return "Symbol(%s, %s)".format(this.identifier, this.type);
    }
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
        if(this.parent){
            auto tmp = parent.lookup(id);
            if(!tmp.isNull){
                sym = sym ? sym : &tmp.get();
            }
        }
        if(sym){
            return nullable(*sym);
        }
        return Nullable!(Symbol).init;
    }

    void insert(string id, Symbol s)
    {
        this.symbols[id] = s;
    }

    override string toString() const
    {
        string ret;
        foreach(k, v; this.symbols){
            ret ~= "%s : %s\n".format(k, v.toString);
        }
        return ret;
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
private:
    Symbol[string] symbols;
    SymbolTable parent;
    SList!SymbolTable children;
};
