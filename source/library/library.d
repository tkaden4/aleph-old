module library.library;

import semantics.SymbolTable;
import parse.Parser;
import semantics;
import util;
import std.conv;
import std.stdio;
import core.stdc.stdlib;


public auto loadLibrary(string path, AlephTable into)
{
    auto x = getenv("ALEPH_STD").to!string;
    x.writeln;
    return into.then!(x => x.addLibrary(path,
            Parser.fromFile(path)
                 // parse program
                 .program
                 // build symbol table
                 .buildSymbols
                 // inference all types
                 .resolveTypes
                 // Perform all type checking
                 .checkTypes
                 // Desugar the tree
                 .desugar[0]
            ));
}
