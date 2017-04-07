module syntax.tree.StatementNode;

import syntax.tree.ExpressionNode;

class StatementNode : ExpressionNode {
    final override Type resultType()
    {
        return Primitives.Void;
    }
};
