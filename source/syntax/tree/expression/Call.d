module syntax.tree.expression.Call;

import syntax.tree.expression.Expression;
import semantics.type.UnknownType;
import util.match;

public class Call : Expression {
    this(Expression toCall, Expression[] args)
    {
        super(toCall.resultType.match(
            (FunctionType f) => f.returnType,
            (Type t)         => new UnknownType
        ));
        this.toCall = toCall;
        this.arguments = args;
    }

    invariant
    {
        assert(this.toCall !is null, "tocall is null");
    }

    override string toString() const
    {
        import std.string;
        return "Call(%s, %s, %s)".format(this.toCall, super.resultType, this.arguments);
    }

    Expression toCall;
    Expression[] arguments;
};
