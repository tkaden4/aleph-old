module semantics.SemaOne;

/* 
   Adds all declarations to the symbol table
 */

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
        foreach(x; node.children){
            x.visit(this);
        }
    }

    void visitProcDecl(ProcDeclNode node)
    {
        Type[] param_types;
        foreach(p; node.parameters){
            param_types ~= p.type;
        }
    }

    void visitCallNode(CallNode node)
    {
        node.toCall.visit(this);
        foreach(x; node.arguments){
            x.visit(this);
        }
    }

    void visitBlockNode(BlockNode node)
    {
        this.res = this.result.enterScope;
        foreach(n; node.children){
            n.visit(this);
        }
        this.res = this.result.leaveScope;
    }

    void visitVarDecl(VarDeclNode node)
    {
        this.res.insert(node.name, Symbol(node.name, node.type));
    }

    void visitIdentifierNode(IdentifierNode node)
    {
        auto symbol = this.result.lookup(node.name);
        if(symbol.isNull){
            throw new ASTException("Symbol %s not defined".format(node.name));
        }
        node.resultType = symbol.type;
    }

    void visitIntegerNode(IntegerNode node){}
    void visitCharNode(CharNode node){}
};
