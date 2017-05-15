module syntax.tree.expression.StatementNode;

import syntax.tree.expression.ExpressionNode;

public class StatementNode : ExpressionNode {
    final override Type resultType()
    {
        return PrimitiveType.Void;
    }
};
