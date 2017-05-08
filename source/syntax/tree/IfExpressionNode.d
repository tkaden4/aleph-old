module syntax.tree.IfExpressionNode;

import syntax.tree.ExpressionNode;

public class IfExpressionNode : ExpressionNode {
    this(ExpressionNode ifn, ExpressionNode then, ExpressionNode elsen, Type res)
    {
        this.ifexp = ifn;
        this.thenexp = then;
        this.elseexp = elsen;
        this._resultType = res;
    }

    override @property Type resultType()
    {
        return this._resultType;
    }

    override string toString() const
    {
        import std.string;
        return "IfNode(%s, %s%s)".format(this.ifexp, this.thenexp, this.elseexp ? ", %s".format(this.elseexp) : "");
    }

    ExpressionNode ifexp;
    ExpressionNode thenexp;
    ExpressionNode elseexp;
private:
    Type _resultType;
};
