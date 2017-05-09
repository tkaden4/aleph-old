module syntax.tree.CharNode;

import syntax.tree.ExpressionNode;

public class CharNode : ExpressionNode {
public:
    this(char value)
    {
        this._value = value;
    }

    override Type resultType()
    {
        return PrimitiveType.Char;
    }

    override string toString() const
    {
        import std.string;
        return "CharNode(%c)".format(this.value);
    }

    @property char value() const
    {
        return this._value;
    }
private:
    char _value;
};
