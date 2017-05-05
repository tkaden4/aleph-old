module semantics.SymbolTable;

import util;

private import semantics.symbol.Symbol;
private import std.stdio;

public class SymbolTable(SymbolType) {
public:
    this(SymbolTable!SymbolType p=null)
    {
        this._parent = p;
    }

    SymbolTable globalTable()
    {
        return this.parent.use!(x => x.globalTable).or(this);
    }

    SymbolType find(string id, bool upper=true)
    {
        return (id in this.symbols)
                    .use!(x => *x)
                    .or(upper ? this.parent.use!(x => x.find(id)) : null);
    }

    SymbolType insert(string id, SymbolType sym)
    {
        return sym.then!(x => this.symbols[id] = sym);
    }

    @property auto parent()
    {
        return this._parent;
    }
private:
    SymbolType[string] symbols;
    SymbolTable!SymbolType _parent;
};
