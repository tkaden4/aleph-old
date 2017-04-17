module syntax.ctree.CLiteralNode;

import syntax.ctree.CExpressionNode;

public interface CLiteralNode : CExpressionNode {};

public class IntLiteral : CLiteralNode {
    this(int value)
    {
        this.value = value;
    }

    @property CType type()
    {
        return CPrimitives.Int;
    }

    int value;
};

public class StringLIteral : CLiteralNode {
    this(string value)
    {
        this.value = value;
    }

    @property CType type()
    {
        return new CPointerType(CPrimitives.Char);
    }

    string value;
};
