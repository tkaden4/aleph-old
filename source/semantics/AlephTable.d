module semantics.AlephTable;

import semantics.SymbolTable;
import semantics.symbol;
private import std.range;
private import std.algorithm;

public class AlephTable : SymbolTable!Symbol {
    this(AlephTable p = null)
    {
        super(p);
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
        return libsyms[0];
    }

    void addLibrary(string path, AlephTable symbols)
    {
        this.libraries[path] = symbols;
    }
private:
    AlephTable[string] libraries;
};
