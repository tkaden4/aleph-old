module semantics.type.PrimitiveType;

import semantics.type.Type;

public class PrimitiveType : Type {
public:
    this(PrimitiveType.PType _type)
    {
        this._type = _type;
    }

    invariant
    {
        assert(this._type);
    }

    @property auto type() pure
    {
        return this._type;
    }

    override string toString() const
    {
        import std.string;
        return "Primitive(%s)".format(this._type);
    }

    override bool canCast(Type t)
    {
        import util;
        return t.match(
            (PrimitiveType t) => t.type == this.type,
            () => false
        );
    }

    static enum {
        Long  = new PrimitiveType(PType.LONG),
        Int   = new PrimitiveType(PType.INT),
        Char  = new PrimitiveType(PType.CHAR),
        ULong = new PrimitiveType(PType.ULONG),
        UInt  = new PrimitiveType(PType.UINT),
        Void  = new PrimitiveType(PType.VOID),
    };

    public static enum PType {
        LONG,
        INT,
        CHAR,
        UINT,
        ULONG,
        VOID,
    };
private:
    PrimitiveType.PType _type;
};

public string primString(PrimitiveType type)
{
    //return type.repString;
    final switch(type.type){
    case PrimitiveType.PType.ULONG: return "ulong";
    case PrimitiveType.PType.UINT:  return "uint";
    case PrimitiveType.PType.LONG:  return "long";
    case PrimitiveType.PType.INT:   return "int";
    case PrimitiveType.PType.CHAR:  return "char";
    case PrimitiveType.PType.VOID:  return "void";
    }
}

public PrimitiveType toPrimitive(string s)
{
    import std.string;
    switch(s){
    case "void": return PrimitiveType.Void;
    case "int": return PrimitiveType.Int;
    case "char": return PrimitiveType.Char;
    case "long": return PrimitiveType.Long;
    case "uint": return PrimitiveType.UInt;
    case "ulong": return PrimitiveType.ULong;
    default: throw new Exception("Could not convert \"%s\" to primitive".format(s));
    }
}
