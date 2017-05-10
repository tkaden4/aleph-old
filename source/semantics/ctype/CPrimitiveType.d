module semantics.ctype.CPrimitiveType;

import semantics.ctype.CType;

public class CPrimitiveType : CType {
public:
    this(in string name, bool signed, size_t size)
    {
        this.name = name;
        this.signed = signed;
        this.size = size;
    }

    override string toString() const
    {
        import std.string;
        return "CPrimitive(%s)".format(this.name);
    }

    string name;
    bool signed;
    size_t size;

    static enum {
        Int   = new CPrimitiveType("int", true, 4),
        Void  = new CPrimitiveType("void", false, 0),
        Char  = new CPrimitiveType("char", true, 1),
        Long  = new CPrimitiveType("long long", true, long.sizeof),
        UInt  = new CPrimitiveType("unsigned", false, uint.sizeof),
        ULong = new CPrimitiveType("unsigned long long", false, ulong.sizeof),
    };
};
