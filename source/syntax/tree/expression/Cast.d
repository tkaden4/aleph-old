module syntax.tree.expression.Cast;

import syntax.tree.expression.Expression;

public class Cast : Expression {
    this(Expression node, Type to)
    {
        super(to);
        this.node = node;
        this.castType = to;
    }

    invariant
    {
        assert(this.node);
        assert(this.castType);
    }

    override string toString() const
    {
        import std.string;
        return "Cast(%s, %s)".format(this.node, this.castType);
    }
    
    Expression node;
    Type castType;
};
