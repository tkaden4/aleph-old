module semantics.SymbolBuilder;

/* 
 * Creates the symbol table and performs type inferencing
 */

import syntax.tree.visitors.ASTVisitor;

import semantics.symbol;
import semantics.SymbolTable;
import semantics.type;

import util;

import std.string;
import std.range;
import std.algorithm;
import std.stdio;
import std.typecons;

private alias AlephTable = SymbolTable!Symbol;

public auto buildSymbols(ProgramNode node)
{
    try{
        return node.build(new AlephTable);
    }catch(Exception ex){
        throw new Exception("couldn't build types: %s".format(ex.msg));
    }
}

private auto build(ProgramNode node, AlephTable table)
{
    return tuple(table, node.then!(k => 
                k.children.map!(x => 
                    x.build(table)).array));
}

private auto build(ReturnNode node, AlephTable table)
{
    node.value.apply!(x => x.build(table));
    return node;
}
private auto build(StatementNode node, AlephTable table)
{
    return node.match(
        (ReturnNode n)   => cast(StatementNode)n.build(table),
        (VarDeclNode n)  => cast(StatementNode)n.build(table),
        (ProcDeclNode n) => cast(StatementNode)n.build(table)
    );
}


private ExpressionNode build(ExpressionNode node, AlephTable table)
{
    return node.use!(x => x.match(
        (StatementNode n)  => cast(ExpressionNode)n.build(table),
        (BlockNode n)      => cast(ExpressionNode)n.build(table),
        (IdentifierNode n) => cast(ExpressionNode)n.build(table),
        (CallNode n)       => cast(ExpressionNode)n.build(table),
        (IntegerNode n)    => n,
        (CharNode n)       => n
    ));
}

private auto build(ProcDeclNode n, AlephTable t)
{
    if(t.find(n.name)){
        throw new Exception("function %s already defined".format(n.name));
    }
    // TODO fix inferred types
    return new AlephTable(t).use!((x){
        t.insert(n.name, new FunctionSymbol(n.name, n.functionType, x));
        n.parameters.each!(k => x.insert(k.name, new VarSymbol(k.name, k.type, x)));
        n.bodyNode = n.bodyNode.build(x);
        return n;
    });
}

private auto build(CallNode n, AlephTable t)
{
    n.toCall = n.toCall.build(t);
    n.arguments = n.arguments.map!(x => x.build(t)).array;
    return n;
}

private auto build(VarDeclNode n, AlephTable t)
{
    n.init = n.init.build(t);
    return n;
}

private auto build(BlockNode node, AlephTable t)
{
    node.children = node.children.map!(x => x.build(t)).array;
    return node;
}

private auto build(IdentifierNode node, AlephTable t)
{
    if(!t.find(node.name)){
        throw new Exception("Symbol %s is not defined".format(node.name));
    }
    return node;
}
