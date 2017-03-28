module gen.Generator;

import symbol.SymbolTable;
import parse.visitors.ASTVisitor;
import parse.visitors.ASTPrinter;

import std.container;

class Generator {
    this()
    {
        this.visitor = new ASTPrinter;
    }
    void generate(ASTNode node)
    {
        node.visit(this.visitor);
    }
private:
    SymbolTable table;
    ASTVisitor visitor;
    SList!string result_stack;
};
