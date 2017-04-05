module parse.visitors.ASTVisitor;

public import parse.ASTException;
public import parse.nodes.ASTNode;
public import parse.nodes.ProcDeclNode;
public import parse.nodes.IntegerNode;
public import parse.nodes.BlockNode;
public import parse.nodes.CharNode;
public import parse.nodes.IdentifierNode;
public import parse.nodes.VarDeclNode;
public import parse.nodes.ProgramNode;
public import parse.nodes.CallNode;
public import parse.nodes.ReturnNode;
public import parse.nodes.StatementNode;

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
