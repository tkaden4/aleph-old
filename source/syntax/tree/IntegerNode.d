module syntax.tree.IntegerNode;

import syntax.tree.ExpressionNode;

public class IntegerNode : ExpressionNode {
public:
    this(int value)
    {
        this.val = value;
    }

    auto value()
    {
        return this.val;
    }

    override Type resultType()
    {
        return PrimitiveType.Int;
    }
    
    override string toString() const
    {
        import std.string;
        return "IntegerNode(%d)".format(this.val);
    }
private:
    int val;
};
