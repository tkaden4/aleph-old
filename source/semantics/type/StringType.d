module semantics.type.StringType;

import semantics.type;

public class StringType : PointerType {
    this()
    {
        super(new QualifiedType(TypeQualifier.Const, Primitives.Char));
    }

    override string toString() const
    {
        return "StringType";
    }
};
