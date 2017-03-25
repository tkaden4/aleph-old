module parse.nodes.ASTVisitor;

public import std.string;
public import parse.nodes.ASTException;
public import parse.nodes.ASTNode;
public import parse.nodes.ProcDeclNode;
public import parse.nodes.IntegerNode;
public import parse.nodes.BlockNode;
public import parse.nodes.CharNode;

class ASTVisitor {
    void visitBasic(ASTNode node)
    {
        throw new ASTException("Cannot visit basic node");
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
};
