module parse.nodes.IntegerNode;

import parse.nodes.ExpressionNode;
import parse.nodes.ASTVisitor;

import symbol.Type;

class IntegerNode : ExpressionNode {
public:
    this(long value)
    {
        this.value = value;
    }

    auto getValue() const
    {
        return this.value;
    }
    
    override void visit(ASTVisitor tv){ tv.visitIntegerNode(this); }

    override bool hasResult() const
    {
        return true;
    }

    override const(Type) getResultType() const
    {
        return Primitives.Int;
    }

    override string toString() const
    {
        import std.string;
        return "IntegerNode(%d)".format(this.value);
    }
private:
    long value;
};
