module semantics.type.PrimitiveType;

import semantics.type.Type;


public class PrimitiveType : Type {
public:
    this(uint _type)
    {
        this._type = _type;
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
            (Type t) => false
        );
    }

    static enum {
        Long = new PrimitiveType(LONG),
        Int = new PrimitiveType(INT),
        Char = new PrimitiveType(CHAR),
        ULong = new PrimitiveType(ULONG),
        UInt = new PrimitiveType(UINT),
        Void = new PrimitiveType(VOID),
    };

    public static enum {
        LONG,
        INT,
        CHAR,
        UINT,
        ULONG,
        VOID,
    };
private:
    uint _type;
};

public string primString(PrimitiveType type)
{
    //return type.repString;
    final switch(type.type){
    case PrimitiveType.ULONG: return "ulong";
    case PrimitiveType.UINT:  return "uint";
    case PrimitiveType.LONG:  return "long";
    case PrimitiveType.INT:   return "int";
    case PrimitiveType.CHAR:  return "char";
    case PrimitiveType.VOID:  return "void";
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
