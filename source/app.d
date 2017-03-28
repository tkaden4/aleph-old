import std.stdio;
import std.string;
import std.file;
import std.range;
import std.algorithm;

import parse.lex.Lexer;
import parse.lex.FileInputBuffer;

import parse.Parser;
import parse.visitors.ASTPrinter;

import semantics.SemaOne;

import gen.Generator;

void main(string[] args)
{
    if(args.length != 2){
        "Not enough arguments".writeln;
        return;
    }

    "====== Compiling \"%s\" ======".format(args[1]).writeln;
    auto lexer = new Lexer(new FileInputBuffer(args[1]));
    auto parser = new Parser(lexer);
    auto program = parser.program;

    auto find_sym = new SemaOne;
    program.visit(find_sym);

    auto symbols = find_sym.result;

    program.visit(new ASTPrinter);
    "\n\n".write;
}
