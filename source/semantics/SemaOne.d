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
        super(new SymbolTable);
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
        this.res.enterScope;
        Type[] param_types;
        foreach(p; node.parameters){
            param_types ~= p.type;
            this.res.insert(p.name, Symbol(p.name, p.type));
        }
        node.bodyNode.visit(this);
        this.res.leaveScope;

        if(!node.returnType){
            node.returnType = node.exp.resultType;
        }
        if(node.returnType != node.exp.resultType){
            throw new ASTException("Type Mismatch");
        }
        this.result.insert(node.name, Symbol(node.name,
                                new FunctionType(node.returnType, param_types)));
    }

    void visitCallNode(CallNode node)
    {
        node.toCall.visit(this);
        foreach(x; node.arguments){
            x.visit(this);
        }
        auto type = node.toCall.resultType.asFunction;
        if(!type){
            throw new ASTException("%s is not a function".format(node.toCall));
        }
        node.resultType = type.returnType;
    }

    void visitBlockNode(BlockNode node)
    {
        this.res = this.result.enterScope;
        foreach(n; node.children){
            n.visit(this);
        }
        node.resolveType;
        this.res = this.result.leaveScope;
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
        auto symbol = this.result.lookup(node.name);
        if(symbol.isNull){
            throw new ASTException("No symbol with id %s".format(node.name));
        }
        node.resultType = symbol.type;
    }

    void visitIntegerNode(IntegerNode node){}
    void visitCharNode(CharNode node){}
};
