module semantics.TypeChecker;

import semantics;
import syntax.tree;
import syntax.visit.Visitor;
import AlephException;
import util;

import std.typecons;
import std.range;
import std.algorithm;
import std.string;
import std.stdio;

public auto checkTypes(Tuple!(ProgramNode, AlephTable) t)
{
    new TypeCheckerVisitor().dispatch(t[0]);
    return t;
}

private void checkCast(Type a, Type b, string extra="")
{
    a.canCast(b).err(new AlephException("couldn't cast %s to %s, %s".format(a, b, extra)));
}

private class TypeCheckerVisitor : Visitor!void {
    override void visit(ref ProcDeclNode node)
    {
        node.returnType.checkCast(node.bodyNode.resultType, "in function %s".format(node.name));
    }

    override void visit(ref VarDeclNode node)
    {
        node.type.checkCast(node.initVal.resultType, "in variable %s".format(node.name));
    }
};
