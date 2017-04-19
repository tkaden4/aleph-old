module semantics.TypeResolver;

/* 
 * Performs all type inferencing
 */

import syntax.tree;
import semantics.SymbolTable;
import std.typecons;
import std.algorithm;
import util;

public auto resolveTypes(Tuple)(Tuple t)
{
    return t.expand.resolveTypes;
}

public auto resolveTypes(AlephTable table, ProgramNode node)
{
    return tuple(table, node.resolve(table));
}

private auto resolve(ProgramNode node, AlephTable table)
{
    return node.then!((auto ref x) =>
                    x.children = x.children.map!(x => x.resolve(table)).array
                );
}

private auto resolve(StatementNode node, AlephTable table)
{
    return node;
}

private ExpressionNode resolve(ExpressionNode node, AlephTable table)
{
    return node.match(
        (StatementNode n) => cast(ExpressionNode)node.resolve(table)
    );
}
