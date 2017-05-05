module semantics.AlephTable;

import semantics.SymbolTable;
import semantics.symbol;

public class AlephTable : SymbolTable!Symbol {
    this(AlephTable p = null)
    {
        super(p);
    }

    void addLibrary(string path, AlephTable symbols)
    {
        this.libraries[path] = symbols;
    }
private:
    AlephTable[string] libraries;
};
