module semantics.SemaOne;

/* 
 * Creates the symbol table and performs type inferencing
 */

import syntax.tree.visitors.ASTVisitor;

import semantics.symbol;
import semantics.type;

import util;

import std.string;
import std.range;
import std.algorithm;
import std.stdio;
import std.typecons;

public auto buildTypes(ProgramNode node)
{
    return tuple(new SemaOne().apply(node), node);
}

private class SemaOne : ASTVisitor {
public:
    SymbolTable result;

    this(){ this.result = new SymbolTable; }

    auto apply(ASTNode node)
    {
        this.dispatch(node);
        return this.result;
    }
public override:
    void visit(ProgramNode node)
    {
        node.children.each!(x => this.dispatch(x));
    }

    void visit(ReturnNode node)
    {
        node.value.apply!(x => this.dispatch(x));
    }

    void visit(ProcDeclNode node)
    {
        /* Create the symbol to be added to table */
        auto bodyScope = new SymbolTable(this.result);

        auto sym = node.returnType.use!(
            x => new FunctionSymbol(node.name, node.functionType, bodyScope)
        ).or(
            node.bodyNode.resultType.use!(
                (x){
                    node.returnType = x;
                    auto ret = new FunctionSymbol(node.name, node.functionType, bodyScope);
                    return ret;
                }
            ).or(new FunctionSymbol(node.name, null, bodyScope))
        );

        /* Add the symbol for the function */
        auto thissym = this.result.insert(node.name, sym);

        /* visit the body with a new scope*/
        this.result = bodyScope;

        foreach(x; node.parameters){
            /* add parameters to the symbol table */
            bodyScope.insert(x.name, new VarSymbol(x.name, x.type, bodyScope.parent));
        }


        this.dispatch(node.bodyNode);

        this.result = this.result.parent;

        /* Check for unresolved type */
        node.bodyNode.resultType.if_then!(
            (x){
                node.returnType = x;
                thissym.match(
                    (FunctionSymbol fun){
                        if(!fun.type){
                            fun.type = node.functionType;
                        }
                    }
                );
            }
        );
    }

    void visit(CallNode node)
    {
        this.dispatch(node.toCall);
        node.arguments.each!(x => this.dispatch(x));
        node.resultType = node.toCall
            .use!(exp => exp.resultType)
            .use!(fnres => fnres.match((FunctionType f) => f))
            .use_err!(fn => fn.returnType)(new ASTException("Cannot call non-function"))
            .use_err!(ret => ret)(new ASTException("Unknown return type"));
    }

    void visit(BlockNode node)
    {
        node.children.each!(x => this.dispatch(x));
        node.resultType = node.children
            .use!(x => x.back)
            .use!(x => x.resultType)
            .use_err!(x => x)(new ASTException("Result type unknown"));
    }

    void visit(VarDeclNode node)
    {
        auto res = this.result.insert(node.name, new VarSymbol(node.name, node.type, this.result));
        this.dispatch(node.init);
        node.type = node.type
            .or(node.init.resultType)
            .if_then!(x => res.type = x);
    }

    void visit(IdentifierNode node)
    {
        auto sym = this.result[node.name];
        node.resultType = sym
            .use_err!(x => x.type)(new ASTException("No symbol defined with name %s".format(node.name)))
            .use_err!(x => x)(new ASTException("Type of %s unknowable at this point".format(node.name)));
    }

    void visit(IntegerNode node){}
    void visit(CharNode node){}
};
