module gen.CGenerator;

import std.file;
import stdio = std.stdio;
import std.range;
import std.conv;

import syntax.ctree;
import syntax.transform;

public import gen.OutputBuilder;

public auto cgenerate(CProgramNode node, CSymbolTable table, OutputStream outp)
{
    return new CGenerator(table, new OutputBuilder(outp)).apply(node);
}

private class CGenerator {
private:
    OutputBuilder *ob;
    alias ob this;
    CSymbolTable symtab;
public:
    this(CSymbolTable table, OutputBuilder *builder)
    {
        this.symtab = table;
        this.ob = builder;
    }
    
    auto apply(CProgramNode node)
    {
        this.visit(node);
        return this.ob;
    }

    void visit(CProgramNode node)
    {
    
    }
};

