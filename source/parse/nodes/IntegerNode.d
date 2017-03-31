module parse.nodes.IntegerNode;

import parse.nodes.ExpressionNode;

import symbol.Type;

class IntegerNode : ExpressionNode {
public:
    this(long value)
    {
        this.value = value;
        this.type = Primitives.Int;
    }

    auto getValue() const
    {
        return this.value;
    }

    override Type resultType()
    {
        return this.type;
    }
    
    override void visit(ASTVisitor tv){ tv.visitIntegerNode(this); }

    override string toString() const
    {
        import std.string;
        return "IntegerNode(%d)".format(this.value);
    }
private:
    long value;
    Type type;
};
