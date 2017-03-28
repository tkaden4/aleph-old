module semantics.SemaOne;

/* This is the first semantic check with the following
    responsibliities:
    - Fill the symbol table
    - Check for undefined symbols */

import symbol.SymbolTable;
import symbol.Type;

import parse.visitors.ResultVisitor;

class SemaOne : ResultVisitor!SymbolTable {
public:
    this()
    {
        this.res = new SymbolTable;
    }
public override:
    void visitProgramNode(ProgramNode node)
    {
        import std.stdio;
        foreach(x; node.children){
            x.visit(this);
        }
    }

    void visitProcDecl(ProcDeclNode node)
    {
        node.bodyNode.visit(this);
        Type[] param_types;
        foreach(p; node.parameters){
            param_types ~= p.type;
        }
        if(!node.returnType){
            node.returnType = node.exp.resultType;
        }
        if(node.returnType != node.exp.resultType){
            throw new ASTException("Type Mismatch");
        }
        this.result.insert(node.name, Symbol(node.name,
                                new FunctionType(node.returnType, param_types)));
    }
    
    void visitBlockNode(BlockNode node)
    {
        foreach(n; node.children){
            n.visit(this);
        }
    }

    void visitVarDecl(VarDeclNode node)
    {
        node.init.visit(this);
        if(!node.type){
            node.type = node.init.resultType;
        }
        if(node.type != node.init.resultType){
            throw new ASTException("Type Mismatch");
        }
        this.result.insert(node.name, Symbol(node.name, node.type));
    }

    void visitIdentifierNode(IdentifierNode node)
    {
        /* TODO lookup in table */
    }

    void visitIntegerNode(IntegerNode node){}
    void visitCharNode(CharNode node){}
};
