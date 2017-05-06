module library;

import semantics.SymbolTable;
import parse.Parser;
import semantics;
import util;
import std.conv;
import std.stdio;


public auto loadLibrary(in string path, AlephTable into)
{
    //import core.stdc.stdlib;
    //auto x = getenv("ALEPH_STD").to!string;
    return into.then!(x => x.addLibrary(path,
            Parser.fromFile(path)
                 // parse program
                 .program
                 // build symbol table
                 .buildTypes
                 // inference all types
                 .resolveTypes
                 // Perform all type checking
                 .checkTypes
                 // Desugar the tree
                 .desugar[0]
            ));
}
