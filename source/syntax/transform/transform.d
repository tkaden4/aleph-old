module syntax.transform.transform;

import syntax.ctree;
import syntax.tree;
import semantics;
import semantics.symbol.Symbol;
import AlephException;

import std.range;
import std.algorithm;
import std.string;
import std.stdio;
import std.typecons;

import util;

alias CSymbolTable = SymbolTable!CSymbol;

/* Transform the Aleph AST into the C AST, for 
 * improved error checking and code generation */

public auto transform(Tuple!(ProgramNode, AlephTable) t)
{
    return t.expand.transform;
}

public auto transform(ProgramNode node, AlephTable tab)
{
    try{
        return node.visit(tab);
    }catch(Exception e){
        throw new Exception("couldn't transform tree to C tree: %s".format(e.msg));
    }
}

private auto visit(ProgramNode node, AlephTable tab)
{
    auto table = new CSymbolTable;
    CTopLevelNode[] top = [];
    foreach(n; node.children){
        n.match(
            (ProcDeclNode proc){
                top ~= proc.visit(table, tab);
            },
            (ExternImportNode node){
                top.insertInPlace(0, new CPreprocessorNode("include<%s>".format(node.file)));
            },
            (ExternProcNode node){
                top ~= node.visit(table, tab);
            },
            (ImportNode n){

            },
            () => new AlephException("Invalid Top-Level Declaration")
        );
    }
    return tuple(new CProgramNode(top), table);
}

private auto visit(ExternProcNode node, CSymbolTable ctable, AlephTable table)
{
    return new CExternFuncNode(node.name,
                               node.returnType.visit(table),
                               node.parameterTypes.map!(x => x.visit(table)).array,
                               node.isvararg);
}

private auto visit(ProcDeclNode node, CSymbolTable ctable, AlephTable table)
{
    import std.conv;
    CStatementNode[] bod_s;
    auto ret_type = node.returnType.visit(table);
    auto params = node.parameters.map!(x => CParameter(x.type.visit(table), x.name)).array;
    node.bodyNode.to!BlockNode.children.each!(x => x.match(
        (StatementNode n) => bod_s ~= cast(CStatementNode)n.visit(table),
        (ExpressionNode n) => bod_s ~= cast(CStatementNode)n.visit(table)
    ));
    auto bod = new CBlockStatementNode(bod_s);
    return new CFuncDeclNode(CStorageClass.EXTERN, 
                             ret_type, node.name, 
                             params, bod);
}


private CStatementNode visit(StatementNode n, AlephTable table)
{
    return n.match(
        (VarDeclNode n) => cast(CStatementNode)new CVarDeclNode(CStorageClass.AUTO,
                                                                 n.type.visit(table),
                                                                 n.name,
                                                                 n.initVal.visit(table)),
        (ReturnNode n) => cast(CStatementNode)new CReturnNode(n.value.visit(table)),
    );
}

private CExpressionNode visit(ExpressionNode n, AlephTable table)
{
    return n.match(
        (IntegerNode n)    => cast(CExpressionNode)new IntLiteral(n.value),
        (StringNode n)     => cast(CExpressionNode)new StringLiteral(n.value),
        (CharNode n)       => cast(CExpressionNode)new CharLiteral(n.value),
        (IdentifierNode n) => new CIdentifierNode(n.name, n.type.visit(table)),
        (CallNode n)       => new CCallNode(n.toCall.visit(table), n.arguments.map!(x => x.visit(table)).array),
        () => new AlephException("%s is not a valid C expresion".format(n))
    );
}

// visits anything
private auto visit(ASTNode n)
{
    throw new AlephException("Couldn't visit %s".format(n));
}

private CType visit(Type type, AlephTable table)
{
    import std.conv;
    return type.match(
        (FunctionType t){
            // TODO add typedef
            return cast(CType)new CFunctionType(t.returnType.visit(table), t.parameterTypes.map!(x => x.visit(table)).array);
        },
        (PrimitiveType t){
            switch(t.type){
            case PrimitiveType.INT:   return CPrimitiveType.Int;
            case PrimitiveType.CHAR:  return CPrimitiveType.Char;
            case PrimitiveType.VOID:  return CPrimitiveType.Void;
            case PrimitiveType.LONG:  return CPrimitiveType.Long;
            case PrimitiveType.ULONG: return CPrimitiveType.ULong;
            case PrimitiveType.UINT:  return CPrimitiveType.UInt;
            default:
                throw new AlephException("Unknown primitive %s".format(t));
            }
        },
        (QualifiedType t){
            final switch(t.qualifier){
            case TypeQualifier.Const: return new CQualifiedType(CTypeQualifier.Const, t.type.visit(table));
            }
        },
        (PointerType t) => new CPointerType(t.type.visit(table))
    );
}
