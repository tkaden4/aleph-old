module syntax.transform.CType;

// Sealed Class
public interface CType {};

public class CAliasType : CType {
    this(string name, CType t)
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

public class CPrimitive : CType {
public:
    this(string name, bool signed)
    {
        this.name = name;
        this.signed = signed;
    }
    string name;
    bool signed;
};

public enum CPrimitives {
    Int = new CPrimitive("int", true),
    Void = new CPrimitive("void", false),
    Char = new CPrimitive("char", true),
};

public class CPointerType : CType {
    this(CType type)
    {
        this.type = type;
    }
    CType type;
};

