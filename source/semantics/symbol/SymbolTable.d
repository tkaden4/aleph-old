module semantics.symbol.SymbolTable;

public import semantics.symbol.Symbol;
public import semantics.type.Type;

import std.container;
import std.typecons;
import std.string;

import util;

public final class SymbolTable {
public:
    this(SymbolTable _parent = null)
    {
        this._parent = _parent;
    }

    Symbol *opIndex(string id)
    {
        auto sym = id in this.symbols;
        if(this.parent){
            auto tmp = parent[id];
            sym = tmp.or(sym);
        }
        return sym;
    }

    Symbol insert(string id, Symbol s)
    {
        this.symbols[id] = s;
        return this.symbols[id];
    }

    @property SymbolTable parent()
    {
        return this._parent;
    }

    override string toString()
    {
        return "SymbolTable(%s)".format(this.symbols.length);
    }
private:
    Symbol[string] symbols;
    SymbolTable _parent;
};
