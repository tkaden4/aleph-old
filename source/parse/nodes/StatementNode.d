module parse.nodes.StatementNode;

public import parse.nodes.ASTNode;
import parse.nodes.ExpressionNode;

class StatementNode : ExpressionNode {
    abstract void visit(ASTVisitor tv);

    final override @property Type resultType()
    {
        return Primitives.Void;
    }
};
