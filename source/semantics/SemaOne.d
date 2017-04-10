module semantics.SemaOne;

/* 
 * Creates the symbol table and performs type inferencing
 */

import syntax.tree.visitors.ASTVisitor;
import semantics.symbol.SymbolTable;

import util;

import std.string;
import std.range;
import std.algorithm;
import std.stdio;
import std.typecons;

auto buildTypes(ProgramNode node)
{
    return tuple(new SemaOne().apply(node), node);
}

class SemaOne : ASTVisitor {
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
        auto sym = node.returnType.use!(
            x => new Symbol(node.name, node.functionType, this.result)
        ).or(
            node.bodyNode.resultType.use!(
                (x){
                    node.returnType = x;
                    auto ret = new Symbol(node.name, node.functionType, this.result);
                    return ret;
                }
            ).or(new Symbol(node.name, null, this.result))
        );

        /* Add the symbol for the function */
        auto thissym = this.result.insert(node.name, sym);

        /* visit the body with a new scope*/
        this.result = this.result.enterScope;
        /* add parameters to the symbol table */
        node.parameters
            .each!(x => this.result.insert(x.name, new Symbol(x.name, x.type, this.result)));

        this.dispatch(node.bodyNode);
        this.result = this.result.leaveScope;

        /* Check for unresolved type */
        node.bodyNode.resultType.if_then!(
            (x){
                node.returnType = x;
                thissym.type = node.functionType;
            }
        );
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
        node.resultType = node.children
            .use!(x => x.back)
            .use!(x => x.resultType)
            .use_err!(x => x)(new ASTException("Result type unknown"));
    }

    void visit(VarDeclNode node)
    {
        auto res = this.result.insert(node.name, new Symbol(node.name, node.type, this.result));
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
