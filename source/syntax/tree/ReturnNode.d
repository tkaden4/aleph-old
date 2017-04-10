module syntax.tree.ReturnNode;

import syntax.tree.StatementNode;
import syntax.tree.ExpressionNode;

public class ReturnNode : StatementNode {
public:
    this(ExpressionNode v)
    {
        this._value = v;
    }

    @property auto value()
    {
        return this._value;
    }
private:
    ExpressionNode _value;
};
