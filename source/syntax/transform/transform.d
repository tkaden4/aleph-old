module syntax.transform.transform;

import syntax.tree.visitors.ASTVisitor;
import syntax.ctree;
import syntax.tree;

import semantics.symbol.SymbolTable;

import std.range;
import std.algorithm;
import std.string;
import std.stdio;
import std.typecons;

import util;

// Sealed Class
public interface CType {};

public class CSymbol {
public:
    string name;
    CType type;
};

public class CSymbolTable {
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
    return new CProgramNode(null);
}

private CFuncDeclNode visit(ProcDeclNode node, CSymbolTable ctable, SymbolTable table)
{
    "%s: ".writef(node.name);
    //node.writeln;
    node.functionType.getTypeId.writeln;
    return new CFuncDeclNode(CStorageClass.STATIC, "", "", [], null);
}

private string getTypeId(Type type)
{
    return type.match(
        (FunctionType t){
            string ret = "";
            ret = t.parameterTypes.use!((x){
                x.each!(
                    (k){ ret ~= k.getTypeId; }
                );
                return ret;
            }).or("void");
            return ret ~ " -> %s".format(t.returnType.getTypeId);
        },
        (PrimitiveType t) => t.primString
    );
}
