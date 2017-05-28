module syntax.tree.expression.EmptyExpression;

import syntax.tree.expression.Expression;

public class EmptyExpression : Expression {
    this()
    {
        super(new UnknownType);
    }

    override string toString() const
    {
        return "EmptyExpression";
    }
};
