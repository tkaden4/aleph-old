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

import semantics.SemaOne;
import semantics.Sugar;

import gen.Generator;

auto time(void delegate() func)
{
    const auto start = Clock.currTime;
    func();
    return Clock.currTime - start;
}

void main(string[] args)
{
    if(args.length != 2){
        "Not enough arguments".writeln;
        return;
    }

    "Compiling \"%s\"".writefln(args[1]);

    
    auto parser = new Parser(new Lexer(new FileInputBuffer(args[1])));

    "Compilation took %d usecs\n".writefln(
        time({
            auto program = parser.program;
            auto symbols = program.desugar.resolve_types;
            auto file = stdout;
            auto gen = new Generator(symbols, file);
            gen.generate(program);
        }).total!"usecs"
    );
}
