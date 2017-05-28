module syntax.tree.expression.Lambda;

import syntax.tree.expression.Expression;
import syntax.tree.Parameter;

public class Lambda : Expression {
    this(Parameter[] params, Expression bodyNode)
    {
        super(new UnknownType);
        this.parameters = params;
        this.bodyNode = bodyNode;
    }

    invariant
    {
        assert(this.bodyNode);
    }

    override string toString() const
    {
        import std.string;
        import std.range;
        import std.algorithm;
        return "Lambda(%s, %s)".format(this.parameters.map!"a.name".array, this.bodyNode);
    }

    Expression bodyNode;
    Parameter[] parameters;
};
