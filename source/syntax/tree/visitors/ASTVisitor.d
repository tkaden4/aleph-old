module syntax.tree.visitors.ASTVisitor;

public import syntax.tree.ASTException;
public import syntax.tree.ASTNode;
public import syntax.tree.ProcDeclNode;
public import syntax.tree.IntegerNode;
public import syntax.tree.BlockNode;
public import syntax.tree.CharNode;
public import syntax.tree.IdentifierNode;
public import syntax.tree.VarDeclNode;
public import syntax.tree.ProgramNode;
public import syntax.tree.CallNode;
public import syntax.tree.ReturnNode;
public import syntax.tree.StatementNode;

public import std.string;

// TODO add dispatch()
class ASTVisitor {
    protected final void dispatch(ASTNode node)
    {
        if(node){
            node.visit(this);
        }
    }

    void visitBasic(ASTNode node)
    {
        throw new ASTException("Cannot visit basic node");
    }
    void visitReturnNode(ReturnNode node)
    {
        throw new ASTException("Cannot visit return node");
    }
    void visitCallNode(CallNode node)
    {
        throw new ASTException("Cannot visit call node");
    }
    void visitProgramNode(ProgramNode node)
    {
        throw new ASTException("Cannot visit program node");
    }
    void visitIntegerNode(IntegerNode node)
    {
        throw new ASTException("Cannot visit integer node");
    }
    void visitCharNode(CharNode node)
    {
        throw new ASTException("Cannot visit char node");
    }
    void visitBlockNode(BlockNode node)
    {
        throw new ASTException("Cannot visit block node");
    }
    void visitProcDecl(ProcDeclNode node)
    {
        throw new ASTException("Cannot visit procedure node");
    }
    void visitIdentifierNode(IdentifierNode node)
    {
        throw new ASTException("Cannot visit identifier node");
    }
    void visitVarDecl(VarDeclNode node)
    {
        throw new ASTException("Cannot visit variable declaration node");
    }
};
