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

import syntax.transform;
import syntax.tree.ASTException;

import semantics.SemaOne;
import semantics.Desugar;
import semantics.symbol.SymbolTable;

import gen.CGenerator;

import util;

private auto usage()
{
    static enum usage_msg = "Usage: alephc <file>.al";
    stderr.writeln(usage_msg);
}

int main(string[] args)
{
    if(args.length != 2){
        usage();
        return 0;
    }

    static enum timefmt = "usecs";
    "Compiling \"%s\"".writefln(args[1]);
    try{
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
                    // transform Aleph AST to C AST
                    .expand
                    .transform
                    // generate code
                    .expand
                    .cgenerate(new FileStream("%s.c".format(args[1])));
            }),
            timefmt
        );
        return 0;
    }catch(Exception ex){
        "error: %s\n".format(ex.msg).writeln;
        return 1;
    }
}
