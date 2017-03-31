module semantics.SemaOne;

/* 
   Adds all declarations to the symbol table
 */

import symbol.SymbolTable;
import symbol.Type;

import parse.visitors.ResultVisitor;

import std.stdio;

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

    void visitProcDecl(ProcDeclNode node)
    {
        auto procSymbol = new Symbol(node.name, node.functionType, this.result);
        this.result.insert(node.name, procSymbol);

        this.result = this.result.enterScope;

        foreach(x; node.parameters){
            this.result.insert(x.name, new Symbol(x.name, x.type, this.result));
        }

        node.bodyNode.visit(this);

        this.result = this.result.leaveScope;

        if(!node.returnType){
            node.returnType = node.bodyNode.resultType;
            this.result[node.name].type.asFunction.returnType = node.returnType;
        }
    }

    void visitCallNode(CallNode node)
    {
        node.toCall.visit(this);
        foreach(x; node.arguments){
            x.visit(this);
        }
        if(node.toCall.resultType){
            auto fn = node.toCall.resultType.asFunction;
            if(!fn){
                throw new ASTException("Cannot call non-function");
            }
            node.resultType = fn.returnType;
        }else{
            throw new ASTException("Type of call is unknown");
        }
    }

    void visitBlockNode(BlockNode node)
    {
        foreach(x; node.children){
            x.visit(this);
        }
        node.resolveType;
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
