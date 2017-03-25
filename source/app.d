import std.stdio;
import std.file;
import std.range;
import std.algorithm;

import parse.Parser;
import parse.Lexer;
import parse.Token;
import parse.FileInputBuffer;
import parse.nodes.ASTPrinter;

void main(string[] args)
{
    if(args.length != 2){
        "Not enough arguments".writeln;
        return;
    }
    auto lexer = new Lexer(new FileInputBuffer(args[1]));
    auto parser = new Parser(lexer);
    auto main = parser.program;
    foreach(x; main){
        x.visit(new ASTPrinter);
    }
}
