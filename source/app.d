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

import semantics.SymbolBuilder;
import semantics.TypeResolver;
import semantics.Desugar;
import semantics.SymbolTable;

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
                    // build symbol table
                    .buildSymbols
                    // inference all types
                    .resolveTypes
                    // Desugar the tree
                    .desugar
                    // transform Aleph AST into C AST
                    .transform
                    // generate code
                    .cgenerate(new FileStream("%s.c".format(args[1])));
            }),
            timefmt
        );
        return 0;
    }catch(Exception ex){
        "alephc error:\n    %s\n".writefln(ex.msg);
        return 1;
    }
}
