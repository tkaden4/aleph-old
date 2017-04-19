module syntax.tree.StringNode;

import syntax.tree.ExpressionNode;

public class StringNode : ExpressionNode {
public:
    this(string value)
    {
        this._value = value;
    }

    override Type resultType()
    {
        return new PointerType(Primitives.Char);
    }

    override string toString() const
    {
        import std.string;
        return "StringNode(%s)".format(this.value);
    }

    @property auto value() const
    {
        return this._value;
    }
private:
    string _value;
};
