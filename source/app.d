import std.stdio;
import std.string;
import std.range;

import parse.lex.Lexer;
import parse.lex.FileInputBuffer;
import parse.Parser;
import gen : cgenerate, FileStream;
import semantics;
import syntax;
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
                    // build symbols
                    .buildSymbols
                    // inference all types
                    .resolveTypes
                    // Perform all type checking
                    .checkTypes
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
    }catch(AlephException ex){
        "alephc error:\n\t%s\n".writefln(ex.msg);
        return 1;
    }catch(Exception ex){
        "internal error:\n\t%s\n".writefln(ex.msg);
        return 1;
    }
}
