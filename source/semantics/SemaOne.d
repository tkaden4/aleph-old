module semantics.SemaOne;

/* 
 * Creates the symbol table and performs type inferencing
 */

import syntax.tree.visitors.ASTVisitor;
import symbol.SymbolTable;
import symbol.Type;

import util;

import std.string;
import std.range;
import std.algorithm;
import std.stdio;

auto buildTypes(ProgramNode node)
{
    return tuple(new SemaOne().apply(node), node);
}

class SemaOne : ASTVisitor {//ResultVisitor!SymbolTable {
public:
    SymbolTable result;
    this()
    {
        this.result = new SymbolTable;
    }

    SymbolTable apply(ASTNode node)
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
        Symbol sym;
        if(node.returnType){
            sym = new Symbol(node.name, node.functionType, this.result);
        }else{
            if(node.bodyNode.resultType){
                node.returnType = node.bodyNode.resultType;
                sym = new Symbol(node.name, node.functionType, this.result);
            }else{
                /* No return type, and not trivial to infer */
                sym = new Symbol(node.name, null, this.result);
            }
        }
        /* Make sure we actually created a symbol */
        assert(sym, "Procedure symbol must be defined");
        /* Add the symbol for the function */
        this.result.insert(node.name, sym);
        /* visit the body with a new scope*/
        this.result = this.result.enterScope;
        foreach(x; node.parameters){
            this.result.insert(x.name, new Symbol(x.name, x.type, this.result));
        }
        this.dispatch(node.bodyNode);
        this.result = this.result.leaveScope;

        /* Check for unresolved type */
        if(!node.returnType){
            node.returnType = node.bodyNode.resultType;
            this.result[node.name].type = node.functionType;
        }
    }

    void visit(CallNode node)
    {
        this.dispatch(node.toCall);
        node.arguments.each!(x => this.dispatch(x));

        node.resultType = node.toCall
            .use!(exp => exp.resultType)
            .use!(fnres => fnres.asFunction)
            .use_err!(fn => fn.returnType)(new ASTException("Cannot call non-function"))
            .use_err!(ret => ret)(new ASTException("Unknown return type"));
    }

    void visit(BlockNode node)
    {
        node.children.each!(x => this.dispatch(x));

        static const unknown_type = new ASTException("Result type unknown");
        node.resultType = node.children
            .use_err!(x => x.back)(unknown_type)
            .use_err!(x => x.resultType)(unknown_type)
            .use_err!(x => x)(unknown_type);
    }

    void visit(VarDeclNode node)
    {
        this.dispatch(node.init);
        this.result.insert(node.name,
                new Symbol(node.name, node.resultType, this.result));
    }

    void visit(IdentifierNode node)
    {
        auto sym = this.result[node.name];
        if(sym.isNull){
            throw new ASTException("No symbol defined with name %s".format(node.name));
        }else if(!sym.type){
            throw new ASTException("Type of %s unknowable at this point".format(node.name));
        }else{
            node.resultType = sym.type;
        }
    }

    void visit(IntegerNode node){}
    void visit(CharNode node){}
};
