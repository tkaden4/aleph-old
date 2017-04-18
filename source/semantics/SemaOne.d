module semantics.SemaOne;

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

public auto buildTypes(ProgramNode node)
{
    return node.resolve(new AlephTable);
}

private auto resolve(ProgramNode node, AlephTable table)
{
    return tuple(table, new ProgramNode(
                                node.children.map!(x => x.resolve(table)).array
                            ));
}

private auto resolve(ReturnNode node, AlephTable table)
{
    node.value.apply!(x => x.resolve(table));
    return node;
}
private StatementNode resolve(StatementNode node, AlephTable table)
{
    return node.match(
        (ReturnNode n) => cast(StatementNode)n.resolve(table),
        (VarDeclNode n) => cast(StatementNode)n.resolve(table),
        (ProcDeclNode n) => cast(StatementNode)n.resolve(table)
    );
}

private auto resolve(ProcDeclNode n, AlephTable t)
{
    return new ProcDeclNode(n.name, n.returnType, n.parameters, n.bodyNode.resolve(t));
}

private auto resolve(VarDeclNode n, AlephTable t)
{
    return new VarDeclNode(n.name, n.type, n.init.use!(x => x.resolve(t)));
}

private auto resolve(BlockNode node, AlephTable t)
{
    return new BlockNode(node.children.map!(x => x.resolve(t)).array);
}

private auto resolve(ExpressionNode node, AlephTable table)
{
    return node;
}
