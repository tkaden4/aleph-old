module syntax.tree.IntegerNode;

import syntax.tree.ExpressionNode;

import symbol.Type;

class IntegerNode : ExpressionNode {
public:
    this(long value)
    {
        this.val = value;
        this.type = Primitives.Int;
    }

    auto value()
    {
        return this.val;
    }

    override Type resultType()
    {
        return this.type;
    }
    
    override string toString() const
    {
        import std.string;
        return "IntegerNode(%d)".format(this.val);
    }
private:
    long val;
    Type type;
};
