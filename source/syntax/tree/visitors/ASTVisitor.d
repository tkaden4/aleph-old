module syntax.tree.visitors.ASTVisitor;

public import syntax.tree;

import std.string;
import util;

public class ASTVisitor {
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
                (ExternImportNode node) => visit(node),
                (ExternProcNode node) => visit(node),
                (VarDeclNode node) => visit(node),
                (ExpressionNode node){},
                (ASTNode node) {
                    throw new ASTException("Couldn't visit %s"
                                                .format(typeid(node).toString));
                } 
            );
        })(new ASTException("Unable dispatch null node"));
    }

    void visit(ExternImportNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
    }

    void visit(ImportNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
    }

    void visit(ExternProcNode node)
    {
        throw new ASTException("Couldn't visit %s"
                                    .format(typeid(node).toString));
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
