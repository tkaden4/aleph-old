module syntax.tree.expression.IntPrimitive;

import syntax.tree.expression.Expression;

public class IntPrimitive : Expression {
public:
    this(int value)
    {
        super(PrimitiveType.Int);
        this.val = value;
    }

    auto value()
    {
        return this.val;
    }

    override string toString() const
    {
        import std.string;
        return "Integer(%d)".format(this.val);
    }
private:
    int val;
};
