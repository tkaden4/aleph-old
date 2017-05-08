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
import semantics.symbol;
import syntax.visit.Visitor;

import util;

public auto resolveTypes(Tuple)(Tuple t)
{
    return t.expand.resolveTypes;
}

public auto resolveTypes(AlephTable table, ProgramNode node)
{
    try{
        Visitor!(void, AlephTable) x = new TypeResolver;
        x.visit(node, table);
        return tuple(table, node);
    }catch(Exception e){
        throw new Exception("type resolution issue: %s".format(e.msg));
    }
}

private class TypeResolver : Visitor!(void, AlephTable) {
public:
    override void visit(ref VarDeclNode n, AlephTable t)
    {
        auto sym = t.find(n.name).err(new Exception("Symbol %s not defined".format(n.name)));
        super.visit(n.initVal, t);
        if(!n.type){
            n.type = n.initVal
                       .use!(x => x.resultType)
                       .err(new Exception("Unable to infer type of variable %s".format(n.name)));
        }
        if(!sym.type){
            sym.type = n.initVal.use!(x => x.resultType);
        }
    }

    override void visit(ref BlockNode n, AlephTable t)
    {
        foreach(ref x; n.children){
            super.visit(x, t);
        }
        if(!n.resultType){
            n.resultType = n.children.back.use!(x => x.resultType).or(Primitives.Void);
        }
    }

    override void visit(ref CallNode n, AlephTable table)
    {
        auto x = n.toCall;
        super.visit(x, table);
        n.toCall = x;
        n.arguments.each!((auto ref x) => super.visit(x, table));
        if(!n.resultType){
            n.resultType = n.toCall.resultType.use!(x =>
                            x.match(
                                (FunctionType t) => t.returnType,
                                (Type t) => null.err(new Exception("Cannot call non-function"))
                            ));
        }
    
    }

    override void visit(ref ProcDeclNode node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new Exception("Function %s not defined".format(node.name)));
        auto symtab = (cast(FunctionSymbol)sym);
        auto tab = symtab.bodyScope;
        auto x = node.bodyNode;
        super.visit(x, tab);
        node.bodyNode = x;
        if(!sym.type){
            node.returnType = node.bodyNode.resultType;
            sym.type = node.functionType.err(new Exception("Recursive type checking problem of %s".format(node.name)));
            //"Resolved %s".writefln(node);
        }
    }

    override void visit(ref IdentifierNode node, AlephTable table)
    {
        auto sym = table.find(node.name);
        if(!sym
               .err(new Exception("Identifier %s not defined".format(node.name)))
               .type
          ){
            sym.type = node.resultType.err(new Exception("Couldn't infer type for %s".format(node.name)));
            //"Resolved identifier %s".writefln(node);
        }else{
            if(!node.resultType){
                node.resultType = sym.type;
                //"Resolved node %s %s".writefln(node, node.resultType);
            }
        }
    }
};
