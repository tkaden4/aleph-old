module syntax.tree.expression.BinaryExpression;

import syntax.tree.expression.Expression;

public class BinaryExpression: Expression{
    this(Expression left, Expression right, in string op, Type resType)
    {
        super(resType);
        this.op = op;
        this.left = left;
        this.right = right;
    }

    override string toString() const
    {
        import std.string;
        return "BinaryExpression(%s, %s, %s)".format(this.left, this.right, this.op);
    }
    
    Expression left;
    Expression right;
    const string op;
};
