module syntax.ctree.CLiteralNode;

import syntax.ctree.CExpressionNode;

private import std.string;

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

    override string toString()
    {
        return "IntLiteral(%d)".format(this.value);
    }

    int value;
};

public class StringLiteral : CLiteralNode {
    this(string value)
    {
        this.value = value;
    }

    @property CType type()
    {
        return new CPointerType(CPrimitives.Char);
    }

    override string toString() const
    {
        return "StringLiteral(%s)".format(this.value);
    }

    string value;
};
