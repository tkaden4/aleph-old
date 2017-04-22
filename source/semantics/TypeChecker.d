module semantics.TypeChecker;

import semantics.SymbolTable;
import syntax.tree;

import std.typecons;
import std.range;
import std.algorithm;

public auto checkTypes(Tuple)(Tuple t)
{
    return checkTypes(t[1], t[0]);
}

public auto checkTypes(ProgramNode node, AlephTable table)
{
    return tuple(table, node.check(table));
}

public auto check(ProgramNode node, AlephTable table)
{
    node.children = node.children.map!(x => x.check(table)).array;
    return node;
}

public auto check(StatementNode node, AlephTable table)
{
    return node;
}

private bool checkCast(Type a, Type b)
{
    return a == b;
}

private bool checkQualifiers(QualifiedType a, QualifiedType b)
{
    return a == b;
}
