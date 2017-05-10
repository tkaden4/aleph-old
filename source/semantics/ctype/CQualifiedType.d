module semantics.ctype.CQualifiedType;

import semantics.ctype.CType;

public enum CTypeQualifier {
    Const,
};

public class CQualifiedType : CType {
    this(CTypeQualifier q, CType to)
    {
        this.qualifier = q;
        this.type = to;
    }

    override string toString() const
    {
        import std.string;
        return "CQualifiedType(%s, %s)".format(this.qualifier, this.type);
    }

    CTypeQualifier qualifier;
    CType type;
};
