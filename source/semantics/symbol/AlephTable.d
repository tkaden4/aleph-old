module semantics.symbol.AlephTable;

import semantics.symbol.SymbolTable;
import semantics.symbol;
import util;
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

    Type findAlias(string name)
    {
        auto par = cast(AlephTable)this.parent;
        return this.aliases[name].or(par.use!(x => x.findAlias(name)));
    }

    void addAlias(string name, Type type)
    {
        if(name in this.aliases){
            throw new Exception("alias already exists");
        }
        this.aliases[name] = type;
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
    Type[string] aliases;
    AlephTable[string] libraries;
};
