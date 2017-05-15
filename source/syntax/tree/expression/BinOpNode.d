module syntax.tree.expression.BinOpNode;

import syntax.tree.expression.ExpressionNode;

public class BinOpNode : ExpressionNode {
    this(ExpressionNode _left, ExpressionNode _right, in string op, Type resType)
    {
        this.op = op;
        this.left = _left;
        this.right = _right;
        this.resultType = resType;
    }

    override @property Type resultType()
    {
        return this._resultType;
    }

    @property void resultType(Type t)
    {
        this._resultType = t;
    }

    override string toString() const
    {
        import std.string;
        return "BinOpNode(%s, %s, %s)".format(this.left, this.right, this.op);
    }
    
    ExpressionNode left;
    ExpressionNode right;
    string op;
    Type _resultType;
private:
};
