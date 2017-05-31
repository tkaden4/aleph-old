module library;

import semantics.symbol.SymbolTable;
import parse.Parser;
import semantics;
import gen.CGenerator;
import util;

import std.conv;
import std.string;
import std.stdio;


public auto loadLibrary(AlephTable into, in string path)
{
    import core.stdc.stdlib;
    auto x = getenv("ALEPH_LIB").to!string;
    if(x == ""){
        throw new AlephException("environment variable ALEPH_LIB is not defined");
    }
    auto newPath = x ~ "/" ~ path ~ ".c";
    return into.then!(x => x.addLibrary(path,
            Parser.fromFile(path)
                 .program
                 .buildSymbols
                 .resolveTypes
                 .checkTypes
                 .desugar.use!((x){
                     x.cgenerate(new FileStream(newPath));
                     return x[1];
                 }),
                 newPath
            ));
}
