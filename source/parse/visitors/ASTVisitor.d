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

public import std.string;

class ASTVisitor {
    void visitBasic(ASTNode node)
    {
        throw new ASTException("Cannot visit basic node");
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
