module parse.nodes.StatementNode;

public import parse.nodes.ASTNode;
public import parse.nodes.ASTVisitor;
import parse.nodes.ExpressionNode;

class StatementNode : ExpressionNode {
    abstract void visit(ASTVisitor tv);

    final bool hasResult() const
    {
        return false;
    }

    final const(Type) getResultType() const 
    {
        return Primitives.Void;
    }
};
