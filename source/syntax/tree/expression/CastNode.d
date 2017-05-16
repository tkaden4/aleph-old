module syntax.tree.expression.CastNode;

import syntax.tree.expression.ExpressionNode;

public class CastNode : ExpressionNode {
    this(ExpressionNode node, Type to)
    {
        this.node = node;
        this.castType = to;
    }

    invariant
    {
        assert(this.node);
        assert(this.castType);
    }

    override @property Type resultType()
    {
        return this.castType;
    }

    override string toString()
    {
        import std.string;
        return "CastNode(%s, %s)".format(this.node, this.castType);
    }
    
    ExpressionNode node;
    Type castType;
};
