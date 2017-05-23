module syntax.visitors.ExpressionVisitor;

import syntax.tree.expression;

public class ExpressionVisitor {
    alias NodeType = ExpressionNode;

    public ExpressionNode visit(ExpressionNode n)
    {
        return n;
    }
}
