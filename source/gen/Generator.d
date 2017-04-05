module gen.Generator; 

import std.file;
import std.stdio;
import std.container;

import symbol.SymbolTable;
import parse.visitors.ASTVisitor;
import parse.visitors.ASTPrinter;

import gen.GenUtils;
import gen.GenVisitor;

public void generate(SymbolTable table, ASTNode node, ref File f)
{
    //assert(file, "Cannot generate to null file");
    auto gen = new Generator(table, stdout);
    gen.visit(node);
}

final class Generator {
public:
    this(SymbolTable table, ref File output)
    {
        this(table, &output);
    }

    this(SymbolTable table, File *output)
    {
        assert(output);
        this.visitor = new GenVisitor(table, output);
    }

    void visit(ASTNode node)
    {
        node.visit(this.visitor);
    }
private:
    GenVisitor visitor;
};
