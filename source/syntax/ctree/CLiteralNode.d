module syntax.ctree.CLiteralNode;

import syntax.ctree.CExpressionNode;
import semantics.ctype;

import std.string;

public interface CLiteralNode : CExpressionNode {};

public class IntLiteral : CLiteralNode {
    this(int value)
    {
        this.value = value;
    }

    @property CType type()
    {
        return CPrimitiveType.Int;
    }

    override string toString()
    {
        return "IntLiteral(%d)".format(this.value);
    }

    int value;
};

public class StringLiteral : CLiteralNode {
    this(in string value)
    {
        this.value = value;
    }

    @property CType type()
    {
        return new CPointerType(new CQualifiedType(CTypeQualifier.Const, CPrimitiveType.Char));
    }

    override string toString() const
    {
        return "StringLiteral(%s)".format(this.value);
    }

    string value;
};

public class CharLiteral : CLiteralNode {
    this(char value)
    {
        this.value = value;
    }

    @property CType type()
    {
        return CPrimitiveType.Char;
    }

    override string toString()
    {
        return "CharLiteral(%d)".format(this.value);
    }

    char value;
};
