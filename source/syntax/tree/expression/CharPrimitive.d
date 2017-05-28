module syntax.tree.expression.CharPrimitive;

import syntax.tree.expression.Expression;

public class CharPrimitive : Expression {
public:
    this(char value)
    {
        super(PrimitiveType.Char);
        this._value = value;
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
