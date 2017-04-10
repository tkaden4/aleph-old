module syntax.tree.StatementNode;

import syntax.tree.ExpressionNode;

public class StatementNode : ExpressionNode {
    final override Type resultType()
    {
        return Primitives.Void;
    }
};
