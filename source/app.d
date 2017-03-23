import std.stdio;
import std.file;
import std.range;
import std.algorithm;

import parse.Parser;
import parse.Lexer;
import parse.Token;
import parse.FileInputBuffer;

void main()
{
    auto lexer = new Lexer(new FileInputBuffer("test/tests/test.aleph"));
    auto parser = new Parser(lexer);
    parser.procDecl.writeln;
    parser.procDecl.writeln;
}
