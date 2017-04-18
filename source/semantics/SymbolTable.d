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
        if(this.parent){
            return this._parent.globalTable;
        }
        return this;
    }

    SymbolType *find(string id)
    {
        auto ret = id in this.symbols;
        return ret.or(this._parent.use!(x => x.find(id)));
    }

    SymbolType insert(string id, SymbolType sym)
    {
        this.symbols[id] = sym;
        return sym;
    }

    @property auto parent()
    {
        return this._parent;
    }
private:
    SymbolType[string] symbols;
    SymbolTable!SymbolType _parent;
};
