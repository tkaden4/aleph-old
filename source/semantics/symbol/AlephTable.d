module semantics.symbol.AlephTable;

import semantics.symbol.SymbolTable;
import semantics.symbol;
private import std.range;
private import std.algorithm;

public class AlephTable : SymbolTable!Symbol {
    this(in string name, AlephTable p = null)
    {
        super(p);
        this._name = name;
    }

    override Symbol find(string id, bool upper=true)
    {
        auto libsyms = this.libraries.byValue.map!(x => x.find(id, false)).array;
        auto x = super.find(id, upper);
        if(!libsyms.length){
            return x;
        }
        if(libsyms.length > 1){
            throw new Exception("Conflicting symbols");
        }
        return x ? x : libsyms[0];
    }

    void addLibrary(string path, AlephTable symbols)
    {
        this.libraries[path] = symbols;
    }

    @property name()
    {
        return this._name;
    }
private:
    string _name;
    AlephTable[string] libraries;
};
