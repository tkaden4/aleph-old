module semantics.TypeResolver;

/* 
 * Performs all type inferencing
 */

import syntax.tree;
import semantics.SymbolTable;
import semantics.symbol;
import std.typecons;
import std.algorithm;
import util;
import std.stdio;
import std.string;

public auto resolveTypes(Tuple)(Tuple t)
{
    return t.expand.resolveTypes;
}

public auto resolveTypes(AlephTable table, ProgramNode node)
{
    try{
        return tuple(table, node.resolve(table));
    }catch(Exception e){
        throw new Exception("type resolution issue: %s".format(e.msg));
    }
}

private auto resolve(ProgramNode node, AlephTable table)
{
    return node.then!(x =>
                    x.children = x.children.map!(x => x.resolve(table)).array
                );
}

private StatementNode resolve(StatementNode node, AlephTable table)
{
    return node.match(
        (ProcDeclNode n) => cast(StatementNode)n.resolve(table),
        (VarDeclNode n)  => cast(StatementNode)n.resolve(table)
    );
}

private auto resolve(VarDeclNode n, AlephTable t)
{
    return n;
}

private ExpressionNode resolve(ExpressionNode node, AlephTable table)
{
    return node.match(
        (StatementNode n)  => cast(ExpressionNode)n.resolve(table),
        (IdentifierNode n) => cast(ExpressionNode)n.resolve(table),
        (CallNode n)       => n.resolve(table),
        (BlockNode n)      => n.resolve(table),
        (IntegerNode n)    => n,
    );
}

private auto resolve(BlockNode n, AlephTable table)
{
    n.children = n.children.map!(x => x.resolve(table)).array;
    return n;
}

private auto resolve(CallNode n, AlephTable table)
{
    n.toCall = n.toCall.resolve(table);
    n.arguments = n.arguments.map!(x => x.resolve(table)).array;
    if(!n.resultType){
        n.resultType = n.toCall.resultType;
    }
    return n;
}

private auto resolve(ProcDeclNode node, AlephTable table)
{
    auto sym = table.find(node.name).err(new Exception("Function %s not defined".format(node.name)));
    if(!sym.type){
        node.returnType = node.bodyNode.resultType;
        sym.type = node.functionType.err(new Exception("Recursive type checking problem"));
        "Resolved function %s".writefln(node);
    }
    auto symtab = (cast(FunctionSymbol)sym);
    auto tab = symtab.bodyScope;
    node.bodyNode = node.bodyNode.resolve(tab);
    return node;
}

private auto resolve(IdentifierNode node, AlephTable table)
{
    auto sym = table.find(node.name);
    if(!sym
           .err(new Exception("Identifier %s not defined".format(node.name)))
           .type
      ){
        node.resultType = node.use!(x => x.resultType);
        sym.type = node.resultType.err(new Exception("Couldn't infer type for %s".format(node.name)));
        "Resolved identifier %s".writefln(node);
    }
    return node;
}
