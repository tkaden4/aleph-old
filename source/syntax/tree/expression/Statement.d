module syntax.tree.expression.Statement;

import syntax.tree.expression.Expression;

public class Statement : Expression {
    this()
    {
        super(PrimitiveType.Void);
    }
};
