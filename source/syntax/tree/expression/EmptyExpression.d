module syntax.tree.expression.EmptyExpression;

import syntax.tree.expression.ExpressionNode;

public class EmptyExpression : ExpressionNode {
    final override Type resultType()
    {
        return new UnknownType;
    }
};
