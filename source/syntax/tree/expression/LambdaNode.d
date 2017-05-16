module syntax.tree.expression.LambdaNode;

import syntax.tree.expression.ExpressionNode;
import syntax.tree.Parameter;

public class LambdaNode : ExpressionNode {
    this(Parameter[] params, ExpressionNode bodyNode)
    {
        this.parameters = params;
        this.bodyNode = bodyNode;
    }

    invariant
    {
        assert(this.bodyNode);
    }

    override @property Type resultType()
    {
        return this._rType;
    }

    override string toString()
    {
        import std.string;
        import std.range;
        import std.algorithm;
        return "LambdaNode(%s, %s)".format(this.parameters.map!"a.name".array, this.bodyNode);
    }

    ExpressionNode bodyNode;
    Parameter[] parameters;
private:
    Type _rType;
};
