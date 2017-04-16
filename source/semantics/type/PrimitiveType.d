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

    this(Primitive type)
    {
        this.type = type;
    }

    auto getType() pure
    {
        return this.type;
    }

    override string toString() const
    {
        import std.string;
        return "Primitive(%s)".format(this.type);
    }
private:
    Primitive type;
};

