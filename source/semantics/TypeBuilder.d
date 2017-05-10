module semantics.TypeBuilder;

/* 
 * Creates the symbol table
 */

import semantics;
import semantics.symbol;
import syntax.tree;
import syntax.visit.Visitor;
import AlephException;
import util;

import std.string;
import std.algorithm;
import std.typecons;
import std.stdio;

public auto buildTypes(Tuple!(ProgramNode, AlephTable) t)
{
    return t.expand.buildTypes;
}

public auto buildTypes(ProgramNode node, AlephTable table)
{
    try{
        auto x = new TypeBuilderVisitor();
        x.visit(node, table);
        return tuple(node, table);
        //return node.build(new AlephTable);
    }catch(AlephException ex){
        throw new AlephException("type builder error: %s".format(ex.msg));
    }
}

private class TypeBuilderVisitor : Visitor!(void, AlephTable) {
    override void visit(ref ProgramNode node, AlephTable tab)
    {
        foreach(k; node.children){
            super.visit(k, tab);
        }
    }

//    override void visit(ref BlockNode node, AlephTable table)
//    {
//        /*  TODO  fix blocknodes containing symbol tables
//        foreach(){
//        
//        }
//        */
//    }

    override void visit(ref ReturnNode node, AlephTable tab)
    {
        node.value.apply!(x => super.visit(node, tab));
    }

    override void visit(ref ProcDeclNode node, AlephTable tab)
    {
        if(tab.find(node.name)){
            throw new AlephException("function %s already defined".format(node.name));
        }
        auto bodyTable = new AlephTable("function %s".format(node.name), tab);
        tab.insert(node.name, new FunctionSymbol(node.name, node.functionType, bodyTable, false));
        node.parameters.each!(l => bodyTable.insert(l.name, new VarSymbol(l.name, l.type, bodyTable)));
        this.visit(node.bodyNode, bodyTable);
    }

    override void visit(ref ExternProcNode node, AlephTable tab)
    {
        auto sym = tab.find(node.name);
        if(sym){
            throw new AlephException("Symbol %s already defined".format(node.name));
        }
        tab.insert(node.name, new FunctionSymbol(node.name, node.functionType, tab, true));
    }

    override void visit(ref IdentifierNode node, AlephTable tab)
    {
        auto sym = tab.find(node.name);
        node.resultType = sym 
                             .err(new AlephException("Symbol %s not defined".format(node.name)))
                             .type;
    }

    override void visit(ref ImportNode node, AlephTable table)
    {
        import library;
        table.loadLibrary(node.path);
    }

    override void visit(ref VarDeclNode node, AlephTable table)
    {
        auto x = node.initVal;
        super.visit(x, table);
        node.initVal = x;

        if(table.find(node.name)){
            throw new AlephException("Shadowing of variable %s".format(node.name));
        }else{
            table.insert(node.name, new VarSymbol(node.name, node.type, table));
        }
    }

    override void visit(ref ExpressionNode node, AlephTable table)
    {
        super.visit(node, table);
    }

    override void visit(ref CallNode node, AlephTable table)
    {
        auto c = node.toCall;
        this.visit(c, table);
        node.toCall = c;

        auto args = node.arguments;
        args.each!(x => this.visit(x, table));
        node.arguments = args;

        node.resultType = node.toCall.resultType.use!(x => x.match(
            (FunctionType f) => f.returnType,
            (Type t) => null.err(new AlephException("Cannot call non-function %s of type %s".format(node.toCall, node.toCall.resultType)))
        ));
    }
};
