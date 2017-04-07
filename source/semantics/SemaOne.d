module semantics.SemaOne;

/* 
 * Creates the symbol table and performs type inferencing
 */

import symbol.SymbolTable;
import symbol.Type;
import syntax.tree.visitors.ResultVisitor;
import util;

import std.stdio;

auto buildTypes(ASTNode node)
{
    return tuple(new SemaOne().visit(node), node);
}

class SemaOne : ResultVisitor!SymbolTable {
public:
    this()
    {
        super(new SymbolTable);
    }
public override:
    void visitProgramNode(ProgramNode node)
    {
        foreach(x; node.children){
            x.visit(this);
        }
    }

    void visitReturnNode(ReturnNode node)
    {
        node.value.apply!(x => x.visit(this));
    }

    void visitProcDecl(ProcDeclNode node)
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
        node.bodyNode.visit(this);
        this.result = this.result.leaveScope;

        /* Check for unresolved type */
        if(!node.returnType){
            node.returnType = node.bodyNode.resultType;
            this.result[node.name].type = node.functionType;
        }
    }

    void visitCallNode(CallNode node)
    {
        node.toCall.visit(this);
        foreach(x; node.arguments){
            x.visit(this);
        }

        node.resultType = node.toCall
            .map!(exp => exp.resultType)
            .map!(fnres => fnres.asFunction)
            .map_err!(fn => fn.returnType)(new ASTException("Cannot call non-function"))
            .map_err!(ret => ret)(new ASTException("Unknown return type"));
    }

    void visitBlockNode(BlockNode node)
    {
        foreach(x; node.children){
            x.visit(this);
        }

        import std.range;
        static const unknown_type = new ASTException("Result type unknown");
        node.resultType = node.children
            .map_err!(x => x.back)(unknown_type)
            .map_err!(x => x.resultType)(unknown_type)
            .map_err!(x => x)(unknown_type);
    }

    void visitVarDecl(VarDeclNode node)
    {
        node.init.visit(this);
        this.result.insert(node.name,
                new Symbol(node.name, node.resultType, this.result));
    }

    void visitIdentifierNode(IdentifierNode node)
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

    void visitIntegerNode(IntegerNode node){}
    void visitCharNode(CharNode node){}
};
