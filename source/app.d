import std.stdio;
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
    auto lexer = new Lexer(new FileInputBuffer(args[1]));
    auto parser = new Parser(lexer);
    auto program = parser.program;


    auto sem_one = new SemaOne;
    program.visit(sem_one);
    auto symbols = sem_one.result;
    program.visit(new ASTPrinter);
}
