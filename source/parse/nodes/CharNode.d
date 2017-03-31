module parse.nodes.CharNode;

import parse.nodes.ExpressionNode;

import symbol.Type;

class CharNode : ExpressionNode {
public:
    this(char value)
    {
        this._value = value;
        this.type = Primitives.Char;
    }

    override void visit(ASTVisitor tv){ tv.visitCharNode(this); }

    override Type resultType()
    {
        return this.type;
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
    Type type;
};
