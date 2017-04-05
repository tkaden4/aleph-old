import std.stdio;
import std.string;
import std.file;
import std.range;
import std.algorithm;
import std.datetime;

import parse.lex.Lexer;
import parse.lex.FileInputBuffer;
import parse.Parser;
import parse.visitors.ASTPrinter;
import parse.nodes.ASTNode;
import symbol.SymbolTable;

import semantics.SemaOne;
import semantics.Sugar;

import gen.Generator;

auto time(string type, T)(T func)
{
    const auto start = Clock.currTime;
    func();
    return (Clock.currTime - start).total!type;
}

void main(string[] args)
{
    if(args.length != 2){
        "Not enough arguments".writeln;
        return;
    }
    "Compiling \"%s\"".writefln(args[1]);
    "Compilation took %d usecs\n".writefln(
        time!"usecs"({
            Parser
                .fromFile(args[1])
                // parse the file
                .program
                // simplify tree
                .desugar
                // build symbol table and inference types 
                .resolve_types
                // generate code
                .expand.generate(stdout);
        })
    );
}
