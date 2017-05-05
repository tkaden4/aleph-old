module syntax.transform.CType;

import std.string;

// Sealed Class
public interface CType {};

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
        return "CQualifiedType(%s, %s)".format(this.qualifier, this.type);
    }

    CTypeQualifier qualifier;
    CType type;
};

public class CAliasType : CType {
    this(in string name, CType t)
    {
        this.n = name;
        this.under = t;
    }
public:
    CType underlyingType()
    {
        return this.under;
    }
private:
    string n;
    CType under;
};

public class CFunctionType : CType {
    this(CType ret, CType[] params)
    {
        this.returnType = ret;
        this.parameterTypes = params;
    }

    CType returnType;
    CType[] parameterTypes;
};

public class CPrimitive : CType {
public:
    this(in string name, bool signed, size_t size)
    {
        this.name = name;
        this.signed = signed;
        this.size = size;
    }

    override string toString() const
    {
        return "CPrimitive(%s)".format(this.name);
    }

    string name;
    bool signed;
    size_t size;
};

public enum CPrimitives {
    Int = new CPrimitive("int", true, 4),
    Void = new CPrimitive("void", false, 0),
    Char = new CPrimitive("char", true, 1),
};

public class CPointerType : CType {
    this(CType type)
    {
        this.type = type;
    }
    CType type;
};

