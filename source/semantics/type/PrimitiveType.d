module semantics.type.PrimitiveType;

import semantics.type.Type;

public enum Primitive {
    INT,
    VOID,
    CHAR
};

public enum Primitives {
    Int = new PrimitiveType(Primitive.INT),
    Void = new PrimitiveType(Primitive.VOID),
    Char = new PrimitiveType(Primitive.CHAR)
};

public class PrimitiveType : Type {
public:

    this(Primitive _type)
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
private:
    Primitive _type;
};

public string primString(PrimitiveType type)
{
    final switch(type.type){
    case Primitive.INT: return "int";
    case Primitive.CHAR: return "char";
    case Primitive.VOID: return "void";
    }
}
