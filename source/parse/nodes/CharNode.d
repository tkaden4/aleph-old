module parse.nodes.CharNode;

import parse.nodes.ExpressionNode;
import parse.nodes.ASTVisitor;

import symbol.Type;

class CharNode : ExpressionNode {
public:
    this(char value)
    {
        this.value = value;
    }

    auto getValue() const
    {
        return this.value;
    }
    
    override void visit(ASTVisitor tv){ tv.visitCharNode(this); }

    override bool hasResult() const
    {
        return true;
    }

    override const(Type) getResultType() const
    {
        return Primitives.Char;
    }

    override string toString() const
    {
        import std.string;
        return "CharNode(%c)".format(this.value);
    }
private:
    char value;
};
