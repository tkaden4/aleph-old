module parse.nodes.CharNode;

import parse.nodes.ExpressionNode;

import symbol.Type;

class CharNode : ExpressionNode {
public:
    this(char value)
    {
        this._value = value;
    }

    override void visit(ASTVisitor tv){ tv.visitCharNode(this); }

    override @property Type resultType()
    {
        return Primitives.Char;
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
