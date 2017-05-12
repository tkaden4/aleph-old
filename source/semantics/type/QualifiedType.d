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

    invariant
    {
        assert(this.type);
    }

    override string toString() const
    {
        return "QualifiedType(%s, %s)".format(this.qualifier, this.type);
    }

    override bool canCast(Type t)
    {
        import util;
        return t.match(
            (QualifiedType x) => x.qualifier == this.qualifier && x.type.canCast(this.type),
            (Type t) => false
        );
    }

    TypeQualifier qualifier;
    Type type;
};
