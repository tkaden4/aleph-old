module semantics.TypeChecker;

import semantics;
import syntax.tree;
import AlephException;
import util;

import std.typecons;
import std.range;
import std.algorithm;
import std.string;

public auto checkTypes(Tuple!(ProgramNode, AlephTable) t)
{
    return t.expand.checkTypes;
}

public auto checkTypes(ProgramNode node, AlephTable table)
{
    try{
        return tuple(node.check(table), table);
    }catch(AlephException ex){
        throw new AlephException("type checker error: %s".format(ex.msg));
    }
}

private auto check(ProgramNode node, AlephTable table)
{
    node.children = node.children.map!(x => x.check(table)).array;
    return node;
}

private StatementNode check(StatementNode node, AlephTable table)
{
    return node.match(
        (ProcDeclNode node) => node.check(table),
        (VarDeclNode node) => node.check(table),
        (StatementNode x) => x
    );
}

private CallNode check(CallNode node, AlephTable table)
{
    auto type = cast(FunctionType)node.toCall.resultType;
    if(node.arguments.length != type.parameterTypes.length && !type.isVararg){
        throw new AlephException("wrong number of arguments for function %s of type %s".format(node.toCall, type.toPrintable));
    }
    return node;
}

private VarDeclNode check(VarDeclNode node, AlephTable table)
{
    node.initVal
        .resultType
        .checkCast(node.type)
        .err(new AlephException("cannot cast %s to %s".format(node.initVal.resultType, node.type)));
    return node;
}

private auto check(ProcDeclNode node, AlephTable table)
{
    auto funtable = (cast(FunctionSymbol)table.find(node.name)).bodyScope;
    node.bodyNode
        .resultType
        .checkCast(node.returnType)
        .err(new AlephException("Cannot cast %s to return type %s of procedure %s"
                            .format(node.bodyNode.resultType, node.returnType, node.name)));
    node.bodyNode = node.bodyNode.check(funtable);
    return node;
}

private BlockNode check(BlockNode node, AlephTable table)
{
    node.children = node.children.map!(x => x.check(table)).array;
    return node;
}

private ExpressionNode check(ExpressionNode node, AlephTable table)
{
    return node.match(
        (BlockNode n)      => n.check(table),
        (StatementNode n)  => n.check(table),
        (CallNode n)       => n.check(table),
        (ExpressionNode n) => n
    );
}

private bool checkCast(Type a, Type b)
{
    return a.canCast(b);
}
