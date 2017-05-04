module library.Library;

import semantics.SymbolTable;
import parse.Parser;
import semantics;

public auto loadLibrary(string path, AlephTable into)
{
    return Parser.fromFile(path)
                 // parse program
                 .program
                 // build symbol table
                 .buildSymbols
                 // inference all types
                 .resolveTypes
                 // Perform all type checking
                 .checkTypes
                 // Desugar the tree
                 .desugar[0];
}
