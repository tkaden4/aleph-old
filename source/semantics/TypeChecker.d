module semantics.TypeChecker;

import semantics;
import syntax.tree;

import std.typecons;
import std.range;
import std.algorithm;
import util;
import std.string;

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
    return node.match(
        (ProcDeclNode node) => node.check(table),
        (StatementNode x) => x
    );
}

public auto check(ProcDeclNode node, AlephTable table)
{
    node.bodyNode.resultType.checkCast(node.returnType)
                            .err(new Exception("Cannot cast %s to return type %s of procedure %s"
                                    .format(node.bodyNode.resultType, node.returnType, node.name)));
    return node;
}

private bool checkCast(Type a, Type b)
{
    return true;
}

private bool checkQualifiers(QualifiedType a, QualifiedType b)
{
    return a.qualifier == b.qualifier;
}
