module syntax.tree.StringNode;

import syntax.tree.ExpressionNode;

public class StringNode : ExpressionNode {
public:
    this(in string value)
    {
        this._value = value;
    }

    override Type resultType()
    {
        return new StringType;
    }

    override string toString() const
    {
        import std.string;
        return "StringNode(%s)".format(this.value);
    }

    @property ref const(string) value() const
    {
        return this._value;
    }
private:
    string _value;
};
