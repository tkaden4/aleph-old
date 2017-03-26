import std.stdio;
import std.file;
import std.range;
import std.algorithm;

import parse.lex.Lexer;
import parse.lex.FileInputBuffer;

import parse.Parser;
import parse.visitors.ASTPrinter;

import semantics.SemaOne;

void main(string[] args)
{

    if(args.length != 2){
        "Not enough arguments".writeln;
        return;
    }
    auto lexer = new Lexer(new FileInputBuffer(args[1]));
    auto parser = new Parser(lexer);
    auto program = parser.program;

    auto printer = new ASTPrinter;
    auto sem_one = new SemaOne;

    foreach(x; program){
        x.visit(sem_one);
    }

    foreach(x; program){
        x.visit(printer);
    }

}
