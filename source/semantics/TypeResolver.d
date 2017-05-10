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

public auto resolveTypes(Tuple)(Tuple t)
{
    return t.expand.resolveTypes;
}

public auto resolveTypes(ProgramNode node, AlephTable table)
{
    try{
        Visitor!(void, AlephTable) x = new TypeResolver;
        x.visit(node, table);
        return tuple(table, node);
    }catch(AlephException e){
        throw new AlephException("type resolution issue: %s".format(e.msg));
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
                       .err(new AlephException("Unable to infer type of variable %s".format(n.name)));
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
            n.resultType = n.children.back.use!(x => x.resultType).or(PrimitiveType.Void);
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
                                (Type t) => null.err(new AlephException("Cannot call non-function"))
                            ));
        }
    
    }

    override void visit(ref ProcDeclNode node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("Function %s not defined".format(node.name)));
        auto symtab = (cast(FunctionSymbol)sym);
        auto tab = symtab.bodyScope;
        auto x = node.bodyNode;
        super.visit(x, tab);
        node.bodyNode = x;
        if(!sym.type){
            node.returnType = node.bodyNode.resultType;
            sym.type = node.functionType.err(new AlephException("Recursive type checking problem of %s".format(node.name)));
        }
    }

    override void visit(ref IdentifierNode node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("Identifier %s not defined".format(node.name)));
        if(!sym.type){
            sym.type = node.resultType.err(new AlephException("Couldn't infer type for %s".format(node.name)));
        }else{
            node.resultType = node.resultType.or(sym.type);
        }
    }
};
