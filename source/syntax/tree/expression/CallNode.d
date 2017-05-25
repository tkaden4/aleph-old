module syntax.tree.expression.CallNode;

import syntax.tree.expression.ExpressionNode;
import semantics.type.UnknownType;
import util.match;

public class CallNode : ExpressionNode {
    this(ExpressionNode toCall, ExpressionNode[] args)
    {
        this.toCall = toCall;
        this.arguments = args;
        this.type = toCall.resultType.match(
            (FunctionType f) => f.returnType,
            (Type t)         => new UnknownType
        );
    }

    invariant
    {
        assert(this.toCall !is null, "tocall is null");
    }

    override @property Type resultType()
    {
        return this.type;
    }

    @property void resultType(Type t)
    {
        this.type = t;
    }

    override string toString() const
    {
        import std.string;
        return "Call(%s, %s, %s)".format(this.toCall, this.type, this.arguments);
    }

    ExpressionNode toCall;
    ExpressionNode[] arguments;
private:
    Type type;
};
