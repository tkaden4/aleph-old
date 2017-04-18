module semantics.SymbolTable;

import util;

public final class SymbolTable(SymbolType) {
public:
    this(SymbolTable!SymbolType _parent=null)
    {
        this._parent = _parent;
    }

    SymbolTable globalTable()
    {
        return this.parent.use!(x => x.globalTable).or(this);
    }

    SymbolType *find(string id)
    {
        return (id in this.symbols).or(this._parent.use!(x => x.find(id)));
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
