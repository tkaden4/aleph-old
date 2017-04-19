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
    this(string name, bool signed, size_t size)
    {
        this.name = name;
        this.signed = signed;
        this.size = size;
    }
    string name;
    bool signed;
    size_t size;
};

/* TODO
public static CPrimitive[string] prims = {
    {CPrimitives.Int, "int"}
};
*/

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

