module syntax.tree.BinOpNode;

import syntax.tree.ExpressionNode;

public class BinOpNode : ExpressionNode {
    this(ExpressionNode _left, ExpressionNode _right, in string op, Type resType)
    {
        this.op = op;
        this.left = _left;
        this.right = _right;
        this._resultType = resType;
    }

    override @property Type resultType()
    {
        return this._resultType;
    }

    override string toString() const
    {
        import std.string;
        return "BinOpNode(%s, %s, %s)".format(this.left, this.right, this.op);
    }
    
    ExpressionNode left;
    ExpressionNode right;
    string op;
private:
    Type _resultType;
};
