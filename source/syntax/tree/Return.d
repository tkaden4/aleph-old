module syntax.tree.Return;

import syntax.tree.expression.Statement;
import syntax.tree.expression.Expression;

public class Return : Statement {
public:
    this(Expression v)
    {
        this.value = v;
    }

    override string toString() const
    {
        import std.string;
        return format("Return(%s)", this.value);
    }

    Expression value;
};
