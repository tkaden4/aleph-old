module semantics.symbol.AlephTable;

import semantics.symbol.SymbolTable;
import semantics.symbol;
import util;

import std.range;
import std.algorithm;
import std.typecons;

public class AlephTable : SymbolTable!Symbol {
    this(in string name, AlephTable p = null)
    {
        super(p);
        this._name = name;
    }

    override Symbol find(in string id, bool upper=true)
    {
        auto libsyms = this.libraries.byValue
                                     .map!(x => x[0].find(id, false))
                                     .filter!(x => x)
                                     .array;
        auto x = super.find(id, upper);
        if(!libsyms.length){
            return x;
        }
        if(libsyms.length > 1){
            import std.string;
            throw new AlephException("Conflicting symbols %s".format(libsyms));
        }
        return x ? x : libsyms[0];
    }

    void addLibrary(in string path, AlephTable symbols, string filename)
    {
        this.libraries[path] = tuple(symbols, filename);
    }

    auto ref libraryPaths()
    {
        return this.libraries.byValue.map!(x => x[1]);
    }

    @property name()
    {
        return this._name;
    }
private:
    string _name;
    Tuple!(AlephTable, string)[string] libraries;
};
