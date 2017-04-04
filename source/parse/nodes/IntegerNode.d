module parse.nodes.IntegerNode;

import parse.nodes.ExpressionNode;

import symbol.Type;

class IntegerNode : ExpressionNode {
public:
    this(long value)
    {
        this.val = value;
        this.type = Primitives.Int;
    }

    auto value()
    {
        return this.val;
    }

    override Type resultType()
    {
        return this.type;
    }
    
    override void visit(ASTVisitor tv){ tv.visitIntegerNode(this); }

    override string toString() const
    {
        import std.string;
        return "IntegerNode(%d)".format(this.val);
    }
private:
    long val;
    Type type;
};
