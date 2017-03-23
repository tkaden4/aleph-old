import std.stdio;
import std.file;
import std.range;
import std.algorithm;

import parse.Parser;
import parse.Lexer;
import parse.Token;
import parse.FileInputBuffer;
import parse.nodes.ASTPrinter;

void main()
{
    auto lexer = new Lexer(new FileInputBuffer("test/tests/test.aleph"));
    auto parser = new Parser(lexer);
    auto main = parser.procDecl;
    main.visit(new ASTPrinter);
//  parser.procDecl.writeln;
}
