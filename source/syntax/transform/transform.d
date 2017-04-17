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
import syntax.transform.CType;

public class CSymbol {
public:
    string name;
    CType type;
};

public class CSymbolTable {
    this(CSymbolTable parentTable=null)
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
    return node.visit(tab);
}

private auto visit(ProgramNode node, SymbolTable tab)
{
    auto table = new CSymbolTable;
    CTopLevelNode[] top = [];
    node.children.match_each(
        (ProcDeclNode proc){
            top ~= proc.visit(table, tab);
        },
        (ASTNode node){
            throw new CTreeException("Invalid Top-Level Declaration");
        }
    );
    return tuple(new CProgramNode(top), table);
}

private auto visit(ProcDeclNode node, CSymbolTable ctable, SymbolTable table)
{
    import std.conv;
    CStatementNode[] bod_s;
    auto ret_type = node.returnType.visit(table);
    auto params = node.parameters.map!(x => CParameter(x.type.visit(table), x.name)).array;
    node.bodyNode.to!BlockNode.children.match_each(
        (ExpressionNode n) => bod_s ~= cast(CStatementNode)n.visit(table)
    );
    auto bod = new CBlockStatementNode(bod_s);
    return new CFuncDeclNode(CStorageClass.EXTERN, 
                             ret_type, node.name, 
                             params, bod);
}

private CExpressionNode visit(ExpressionNode n, SymbolTable table)
{
    try{
        auto ret = n.match(
            (IntegerNode n) => cast(CExpressionNode)new IntLiteral(n.value),
            (VarDeclNode n) => cast(CExpressionNode)new CVarDeclNode(CStorageClass.AUTO, n.type.visit(table), n.name),
            (ReturnNode n) => cast(CExpressionNode)new CReturnNode(n.value.visit(table))
        );
        if(!ret){
            throw new Exception("couldnt");
        }
        return ret;
    }catch(Exception e){
        throw new Exception("Couldn't convert %s to expression node".format(n));
    }
}

private auto visit(ASTNode n)
{
    import std.random;
    return new CBlockStatementNode(
                [
                    new CVarDeclNode(CStorageClass.AUTO,
                                      CPrimitives.Int,
                                      "x",
                                      new IntLiteral(uniform(0, 200)))
                ]);
}

private CType visit(Type type, SymbolTable table)
{
    import std.conv;
    return type.match(
        (FunctionType t){
            return new CPrimitive("void", false);
        },
        (Type t){ return new CPrimitive("int", true); }
    );
}
