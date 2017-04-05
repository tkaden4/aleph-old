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

import gen.GenVisitor;

auto map(T, V, alias f)(Tuple!(T, V) t)
{
    return f(t);
}

auto time(string type, T)(T func)
{
    const auto start = Clock.currTime;
    func();
    return (Clock.currTime - start).total!type;
}

auto usage()
{
    static enum usage_msg = "Usage: alephc <file>.al";
    stderr.writeln(usage_msg);
}

auto map(alias func, Args...)(Tuple!Args t)
{
    func(t);
    return t;
}

void main(string[] args)
{
    if(args.length != 2){
        usage();
        return;
    }
    "Compiling \"%s\"".writefln(args[1]);
    "Compilation took %d usecs\n".writefln(
        time!"usecs"({
            Parser
                .fromFile(args[1])
                // parse the file
                .program
                // build symbol table and inference types 
                .build_types
                .map!(x => x[1].desugar)
                // generate code
                .expand.generate(
                            new FileStream(
                                new File("%s.c".format(args[1]) ,"w")));
        })
    );
}
