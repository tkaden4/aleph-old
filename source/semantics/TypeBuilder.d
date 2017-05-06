module semantics.TypeBuilder;

/* 
 * Creates the symbol table
 */

import syntax.tree.visitors.ASTVisitor;

import semantics;
import semantics.symbol;

import util;

import std.string;
import std.algorithm;
import std.stdio;

public auto buildTypes(ProgramNode node)
{
    try{
        return node.build(new AlephTable);
    }catch(Exception ex){
        throw new Exception("type builder error: %s".format(ex.msg));
    }
}

private auto build(ProgramNode node, AlephTable table)
{
    node.err(new Exception("Null node"));
    return tuple(table, 
            node.then!(k => 
                k.children = k.children.map!(x => 
                    x.build(table)).array));
}

private auto build(ReturnNode node, AlephTable table)
{
    node.value.apply!(x => x.build(table));
    return node;
}
private StatementNode build(StatementNode node, AlephTable table)
{
    return node.match(
        (ReturnNode n)   => cast(StatementNode)n.build(table),
        (VarDeclNode n)  => cast(StatementNode)n.build(table),
        (ProcDeclNode n) => cast(StatementNode)n.build(table),
        (ImportNode n){
            import library;
            loadLibrary(n.path, table);
            return n;
        },
        (ExternProcNode n) => n.build(table),
        (ExternImportNode n) => n,
    );
}


private auto build(ExternProcNode node, AlephTable table)
{
    auto sym = table.find(node.name);
    if(sym){
        throw new Exception("Symbol %s already defined".format(node.name));
    }
    table.insert(node.name, new FunctionSymbol(node.name, node.functionType, table, true));
    return node;
}

private ExpressionNode build(ExpressionNode node, AlephTable table)
{
    return node.use!(x => x.match(
        (StatementNode n)  => cast(ExpressionNode)n.build(table),
        (BlockNode n)      => cast(ExpressionNode)n.build(table),
        (IdentifierNode n) => cast(ExpressionNode)n.build(table),
        (CallNode n)       => cast(ExpressionNode)n.build(table),
        (StringNode n)     => n,
        (IntegerNode n)    => n,
        (CharNode n)       => n
    ));
}

private auto build(ProcDeclNode n, AlephTable t)
{
    if(t.find(n.name)){
        throw new Exception("function %s already defined".format(n.name));
    }
    auto k = new AlephTable(t);
    t.insert(n.name, new FunctionSymbol(n.name, n.functionType, k, false));
    n.parameters.each!(l => k.insert(l.name, new VarSymbol(l.name, l.type, k)));
    n.bodyNode = n.bodyNode.build(k);
    return n;
}

private auto build(CallNode n, AlephTable t)
{
    n.toCall = n.toCall.build(t);
    n.arguments = n.arguments.map!(x => x.build(t)).array;
    n.resultType = n.toCall.resultType.use!(x => x.match(
        (FunctionType f) => f.returnType,
        (Type t) => null.err(new Exception("Cannot call non-function"))
    ));
    return n;
}

private auto build(VarDeclNode n, AlephTable t)
{
    n.initVal = n.initVal.build(t);
    if(t.find(n.name)){
        throw new Exception("Shadowing of variable %s".format(n.name));
    }else{
        t.insert(n.name, new VarSymbol(n.name, n.type, t));
    }
    return n;
}

private auto build(BlockNode node, AlephTable t)
{
    node.children = node.children.map!(x => x.build(t)).array;
    return node;
}

private auto build(IdentifierNode node, AlephTable t)
{
    auto sym = t.find(node.name);
    node.resultType = sym 
                         .err(new Exception("Symbol %s not defined".format(node.name)))
                         .type;
    return node;
}
