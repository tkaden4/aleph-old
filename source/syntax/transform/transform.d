module syntax.transform.transform;

import syntax.ctree;
import syntax.tree;
import semantics;
import semantics.symbol.Symbol;
import syntax.print;

import std.range;
import std.algorithm;
import std.string;
import std.stdio;
import std.typecons;

import util;

alias CSymbolTable = SymbolTable!CSymbol;

/* Transform the Aleph AST into the C AST, for 
 * improved error checking and code generation */

public auto transform(Tuple!(Program, AlephTable) t)
{
    return t.expand.transform;
}

public auto transform(Program node, AlephTable tab)
{
    return alephErrorScope("tree transformer", {
        return node.visit(tab);
    });
}

private auto visit(Program node, AlephTable tab)
{
    auto table = new CSymbolTable;
    CTopLevelNode[] top = [];
    foreach(n; node.children){
        n.match(
            (ProcDecl proc){
                top ~= proc.visit(table, tab);
            },
            (ExternImport node){
                top.insertInPlace(0, new CPreprocessorNode("include<%s>".format(node.file)));
            },
            (ExternProc node){
                top ~= node.visit(table, tab);
            },
            () => new AlephException("Invalid Top-Level Declaration\n\t%s".format(n)).raise
        );
    }
    foreach(x; tab.libraryPaths){
        top.insertInPlace(0, new CPreprocessorNode("include\"%s\"".format(x)));
    }
    return tuple(new CProgramNode(top), table);
}

private auto visit(ExternProc node, CSymbolTable ctable, AlephTable table)
{
    return new CExternFuncNode(node.name,
                               node.returnType.visit(table),
                               node.parameterTypes.map!(x => x.visit(table)).array,
                               node.isvararg);
}

private auto visit(ProcDecl node, CSymbolTable ctable, AlephTable table)
{
    import std.conv;
    CStatementNode[] bod_s;
    auto ret_type = node.returnType.visit(table);
    auto params = node.parameters.map!(x => CParameter(x.name, x.type.visit(table))).array;
    node.bodyNode.to!Block.children.each!(x => x.match(
        (Statement n) => bod_s ~= cast(CStatementNode)n.visit(table),
        (Expression n) => bod_s ~= cast(CStatementNode)n.visit(table)
    ));
    auto bod = new CBlockStatementNode(bod_s);
    return new CFuncDeclNode(CStorageClass.EXTERN, 
                             ret_type, node.name, 
                             params, bod);
}


private CStatementNode visit(Statement n, AlephTable table)
{
    return n.match(
        (VarDecl n) => cast(CStatementNode)new CVarDeclNode(CStorageClass.AUTO,
                                                                 n.type.visit(table),
                                                                 n.name,
                                                                 n.initVal.visit(table)),
        (Return n) => new CReturnNode(n.value.visit(table))
    );
}

private CExpressionNode visit(Expression n, AlephTable table)
{
    return n.match(
        (IntPrimitive n)    => cast(CExpressionNode)new IntLiteral(n.value),
        (StringPrimitive n) => cast(CExpressionNode)new StringLiteral(n.value),
        (CharPrimitive n)   => cast(CExpressionNode)new CharLiteral(n.value),
        (Identifier n)   => new CIdentifierNode(n.name, n.resultType.visit(table)),
        (Call n)            => new CCallNode(n.toCall.visit(table), n.arguments.map!(x => x.visit(table)).array),
        (){ throw new AlephException("could not be converted to C:\n%s".format(n.toPretty)); }
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
    return cast(CType)type.match(
        (FunctionType t) => new CFunctionType(t.returnType.visit(table), t.parameterTypes.map!(x => x.visit(table)).array),
        (PrimitiveType t){
            switch(t.type){
            case PrimitiveType.PType.INT:   return CPrimitiveType.Int;
            case PrimitiveType.PType.CHAR:  return CPrimitiveType.Char;
            case PrimitiveType.PType.VOID:  return CPrimitiveType.Void;
            case PrimitiveType.PType.LONG:  return CPrimitiveType.Long;
            case PrimitiveType.PType.ULONG: return CPrimitiveType.ULong;
            case PrimitiveType.PType.UINT:  return CPrimitiveType.UInt;
            default:
                throw new AlephException("Unknown primitive %s".format(t));
            }
        },
        (QualifiedType t){
            final switch(t.qualifier){
            case TypeQualifier.Const: return new CQualifiedType(CTypeQualifier.Const, t.type.visit(table));
            }
        },
        (PointerType t) => new CPointerType(t.type.visit(table)),
        (){ throw new AlephException("could not convert %s to valid C type".format(type.toPrintable)); }
    );
}
