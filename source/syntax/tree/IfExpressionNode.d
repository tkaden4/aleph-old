module syntax.tree.IfExpressionNode;

import syntax.tree.ExpressionNode;

public class IfExpressionNode : ExpressionNode {
    this(ExpressionNode ifn, ExpressionNode then, ExpressionNode elsen, Type res)
    {
        this.ifn = ifn;
        this.then = then;
        this.elsen = elsen;
        this._resultType = res;
    }

    override @property Type resultType()
    {
        return this._resultType;
    }

    override string toString() const
    {
        import std.string;
        return "IfNode(%s, %s%s)".format(this.ifn, this.then, this.elsen ? ", %s".format(this.elsen) : "");
    }

    ExpressionNode ifn;
    ExpressionNode then;
    ExpressionNode elsen;
private:
    Type _resultType;
};
