module syntax.transform.transform;

import syntax.tree.visitors.ASTVisitor;
import syntax.ctree;
import syntax.tree;

import semantics.SymbolTable;
import semantics.symbol.Symbol;

import std.range;
import std.algorithm;
import std.string;
import std.stdio;
import std.typecons;

import util;

//TODO finish implementing

/* Transform the Aleph AST into the C AST, for 
 * improved error checking and code generation */

public auto transform(Tuple)(Tuple t)
{
    return t.expand.transform;
}

public auto transform(SymbolTable!Symbol tab, ProgramNode node)
{
    try{
        return node.visit(tab);
    }catch(Exception e){
        throw new Exception("Couldn't transform tree: %s".format(e.msg));
    }
}

private auto visit(ProgramNode node, SymbolTable!Symbol tab)
{
    auto table = new SymbolTable!CSymbol;
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

private auto visit(ProcDeclNode node, SymbolTable!CSymbol ctable, SymbolTable!Symbol table)
{
    import std.conv;
    CStatementNode[] bod_s;
    auto ret_type = node.returnType.visit(table);
    auto params = node.parameters.map!(x => CParameter(x.type.visit(table), x.name)).array;
    node.bodyNode.to!BlockNode.children.match_each(
        (StatementNode n) => bod_s ~= cast(CStatementNode)n.visit(table),
        (ExpressionNode n) => bod_s ~= cast(CStatementNode)n.visit(table)
    );
    auto bod = new CBlockStatementNode(bod_s);
    return new CFuncDeclNode(CStorageClass.EXTERN, 
                             ret_type, node.name, 
                             params, bod);
}


private CStatementNode visit(StatementNode n, SymbolTable!Symbol table)
{
    return n.match(
        (VarDeclNode n) => cast(CStatementNode)new CVarDeclNode(CStorageClass.AUTO,
                                                                 n.type.visit(table),
                                                                 n.name,
                                                                 n.initVal.visit(table)),
        (ReturnNode n) => cast(CStatementNode)new CReturnNode(n.value.visit(table))
    );
}

private CExpressionNode visit(ExpressionNode n, SymbolTable!Symbol table)
{
    return n.match(
        (IntegerNode n)    => cast(CExpressionNode)new IntLiteral(n.value),
        (StringNode n)     => cast(CExpressionNode)new StringLiteral(n.value),
        (IdentifierNode n) => new CIdentifierNode(n.name, n.type.visit(table)),
        (CallNode n)       => new CCallNode(n.toCall.visit(table), n.arguments.map!(x => x.visit(table)).array),
        // XXX
        (Object n) => null.err(new Exception("Couldn't convert %s to C expresion".format(n)))
    );
}

// visits anything
private auto visit(ASTNode n)
{
    throw new Exception("Couldn't visit %s".format(n));
}

private CType visit(Type type, SymbolTable!Symbol table)
{
    import std.conv;
    return type.match(
        (FunctionType t){
            return cast(CType)new CFunctionType(t.returnType.visit(table), t.parameterTypes.map!(x => x.visit(table)).array);
        },
        (Type t){ return CPrimitives.Int; }
    );
}
