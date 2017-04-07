module syntax.transform.transform;

import syntax.tree.visitors.ASTVisitor;
import syntax.ctree;
import syntax.tree.ProgramNode;

import symbol.SymbolTable;

import std.range;
import std.algorithm;
import std.string;
import std.stdio;

import util;

// Sealed Class
interface CType {};

class CSymbol {
public:
    string name;
    CType type;
};

class CSymbolTable {
    this(CSymbolTable parentTable)
    {
        this.parent = parentTable;
    }

    CSymbolTable globalTable()
    {
        if(this.parent){
            return this.parent.globalTable();
        }
        return this;
    }

    auto insert(string name, CSymbol symbol)
    {
        this.symbols[name] = symbol;
    }
private:
    CSymbol[string] symbols;
    CSymbolTable parent;
};

//TODO finish implementing

/* Transform the Aleph AST into the C AST, for 
 * improved error checking and code generation */

public auto transform(SymbolTable tab, ProgramNode node)
{
    return tuple(node.visit, new CSymbolTable(null));
}

private CProgramNode visit(ProgramNode node)
{
    auto prog = new CProgramNode(null);
    node.children.each!((x){
        x.match(
            (ProcDeclNode proc){
                proc.visit(new CSymbolTable(null), new SymbolTable);
            },
            (ASTNode node){
                throw new CTreeException("Invalid Top-Level Declaration");
            }
        );
    });
    return prog;
}

private CFuncDeclNode visit(ProcDeclNode node, CSymbolTable ctable, SymbolTable table)
{
    return null;
}
