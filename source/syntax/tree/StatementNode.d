module syntax.tree.StatementNode;

import syntax.tree.ExpressionNode;

class StatementNode : ExpressionNode {
    abstract void visit(ASTVisitor tv);
    final override Type resultType()
    {
        return Primitives.Void;
    }
};
