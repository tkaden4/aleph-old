module syntax.tree.expression.Block;

import syntax.tree.expression.Expression;

import std.range;
import util;

public class Block : Expression {
public:
    this(Expression[] children)
    {
        super(new UnknownType);
        this._children = children;
    }

    override string toString() const
    {
        import std.string;
        return "Block(%s)".format(this._children);
    }

    @property auto children()
    {
        return this._children;
    }

    @property void children(Expression[] nodes)
    {
        this._children = nodes;
    }
private:
    Expression[] _children;
};
