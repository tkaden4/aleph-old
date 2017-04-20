module semantics.type.QualifiedType;

import semantics.type.Type;
import std.string;

public enum TypeQualifier {
    Const,
};

public class QualifiedType : Type {
public:
    this(TypeQualifier q, Type type)
    {
        this.qualifier = q;
        this.type = type;
    }

    override string toString() const
    {
        return "QualifiedType(%s, %s)".format(this.qualifier, this.type);
    }

    TypeQualifier qualifier;
    Type type;
};
