module gen.Generator;

import symbol.SymbolTable;
import parse.visitors.ASTVisitor;
import parse.visitors.ASTPrinter;

import std.container;

class Generator {
    this(SymbolTable table)
    {
        this.table = table;
    }
    void generate(ASTNode node)
    {
        node.visit(new ASTPrinter);
    }
private:
    SymbolTable table;
    SList!string result_stack;
};
