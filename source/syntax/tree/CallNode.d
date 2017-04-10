module syntax.tree.CallNode;

import syntax.tree.ExpressionNode;

public class CallNode : ExpressionNode {
    this(ExpressionNode toCall, ExpressionNode[] args)
    {
        this.call = toCall;
        this.args = args;
    }

    invariant
    {
        assert(this.call !is null, "tocall is null");
    }

    override @property Type resultType()
    {
        return this.type;
    }

    @property void resultType(Type t)
    {
        this.type = t;
    }

    @property ExpressionNode toCall()
    {
        return this.call;
    }

    @property ExpressionNode[] arguments()
    {
        return this.args;
    }
private:
    Type type;
    ExpressionNode call;
    ExpressionNode[] args;
};
