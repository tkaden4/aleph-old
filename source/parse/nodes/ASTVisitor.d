module parse.nodes.ASTVisitor;

public import std.string;
public import parse.nodes.ASTException;
public import parse.nodes.ASTNode;
public import parse.nodes.ProcDeclNode;
public import parse.nodes.IntegerNode;
public import parse.nodes.BlockNode;

class ASTVisitor {
    void visitBasic(ASTNode node)
    {
        throw new ASTException("Cannot visit basic node");
    }
    abstract void visitProcDecl(ProcDeclNode node)
    {
        throw new ASTException("Cannot visit procedure node");
    }
};
