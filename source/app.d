import std.stdio;
import std.string;
import std.file;
import std.range;
import std.algorithm;
import std.datetime;
import std.typecons;
import std.traits;

import parse.lex.Lexer;
import parse.lex.FileInputBuffer;
import parse.Parser;
import syntax.tree.visitors.ASTPrinter;
import semantics.SemaOne;
import semantics.Sugar;
import symbol.SymbolTable;
import gen.GenVisitor;
import util;

auto usage()
{
    static enum usage_msg = "Usage: alephc <file>.al";
    stderr.writeln(usage_msg);
}

void main(string[] args)
{
    if(args.length != 2){
        usage;
        return;
    }

    enum timefmt = "usecs";
    "Compiling \"%s\"".writefln(args[1]);
    "Compilation took %d %s\n".writefln(
        time!timefmt({
            Parser
                .fromFile(args[1])
                // parse the file
                .program
                // build symbol table and inference types 
                .buildTypes
                // Desugar the tree
                .then!(x => x[1].desugar)
                // generate code
                .expand.generate(new FileStream(
                                    new File("%s.c".format(args[1]) ,"w")));
        }),
        timefmt
    );
}
