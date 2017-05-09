module syntax.tree.StringNode;

import syntax.tree.ExpressionNode;

public class StringNode : ExpressionNode {
public:
    this(in string value)
    {
        this._value = value;
        this._type = new StringType;
    }

    override Type resultType()
    {
        return this._type;
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
    StringType _type;
};
