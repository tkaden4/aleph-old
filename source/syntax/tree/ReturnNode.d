module syntax.tree.ReturnNode;

import syntax.tree.expression.StatementNode;
import syntax.tree.expression.ExpressionNode;

public class ReturnNode : StatementNode {
public:
    this(ExpressionNode v)
    {
        this.value = v;
    }

    override string toString() const
    {
        import std.string;
        return "ReturnNode(%s)".format(this.value);
    }

    ExpressionNode value;
};
