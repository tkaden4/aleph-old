module semantics.type.StringType;

import semantics.type;

public class StringType : PointerType {
    this()
    {
        super(new QualifiedType(TypeQualifier.Const, PrimitiveType.Char));
    }

    override string toString() const
    {
        return "StringType";
    }
};
