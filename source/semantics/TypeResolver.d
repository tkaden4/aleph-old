module semantics.TypeResolver;

/* 
 * Performs all type inferencing
 */

import std.typecons;
import std.range;
import std.algorithm;
import std.stdio;
import std.string;

import syntax.tree;
import semantics;
import syntax.visit.Visitor;
import AlephException;

import util;

public auto resolveTypes(Tuple!(ProgramNode, AlephTable) t)
{
    return t.expand.resolveTypes;
}

public auto resolveTypes(ProgramNode node, AlephTable table)
in {
    assert(node);
    assert(table);
} out(t) {
    assert(t[0]);
    assert(t[1]);
    assert(t[0]);
} body {
    try{
        new TypeResolver().dispatch(node, table);
        return tuple(node, table);
    }catch(AlephException e){
        throw new AlephException("type resolution issue: %s".format(e.msg));
    }
}

private class TypeResolver : Visitor!(void, AlephTable) {
protected:
    override void visit(ref VarDeclNode n, AlephTable t)
    {
        auto sym = t.find(n.name).err(new Exception("Symbol %s not defined".format(n.name)));
        super.visit(n, t);
    }

    override void visit(ref BlockNode node, AlephTable table)
    {
        super.visit(node, table);
        node.resultType = node.children.back.use!(x => x.resultType).or(PrimitiveType.Void);
    }

    override void visit(ref ProcDeclNode node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("Function %s not defined".format(node.name)));
        sym.match(
            (FunctionSymbol f) => super.visit(node, f.bodyScope),
            (){ throw new AlephException("%s is not defined as a function".format(node.name)); }
        );
    }

    override void visit(ref IdentifierNode node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("Identifier %s not defined".format(node.name)));
        super.visit(node, table);
    }
};
