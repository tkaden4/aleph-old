module syntax.tree.expression.StringPrimitive;

import syntax.tree.expression.Expression;

public class StringPrimitive : Expression {
public:
    this(in string value)
    {
        super(new StringType);
        this._value = value;
    }

    override string toString() const
    {
        import std.string;
        return "String(%s)".format(this.value);
    }

    @property ref const(string) value() const
    {
        return this._value;
    }
private:
    string _value;
};
