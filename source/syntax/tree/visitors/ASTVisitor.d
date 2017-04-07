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

import std.string;
import util;

class ASTVisitor {
    protected final auto dispatch(ASTNode node)
    {
        node.use_err!((x){
            x.match(
                (BlockNode node) => visit(node),
                (ReturnNode node) => visit(node),
                (CallNode node) => visit(node),
                (ProgramNode node) => visit(node),
                (IntegerNode node) => visit(node),
                (CharNode node) => visit(node),
                (ProcDeclNode node) => visit(node),
                (IdentifierNode node) => visit(node),
                (VarDeclNode node) => visit(node),
                (ASTNode node) {
                    throw new ASTException("Couldn't visit %s"
                                                .format(typeid(node).toString));
                } 
            );
        })(new ASTException("Unable dispatch null node"));
    }

    void visit(BlockNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
    }

    void visit(ReturnNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
    }

    void visit(CallNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
    }

    void visit(ProgramNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
    }

    void visit(IntegerNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
    }

    void visit(CharNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
    }

    void visit(ProcDeclNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
    }

    void visit(IdentifierNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
    }

    void visit(VarDeclNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
    }
};
