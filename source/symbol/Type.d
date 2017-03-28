module symbol.Type;

interface TypeVisitor {
    void invoke(Type t);
};

interface Type {
    void visit(TypeVisitor tv);
};

public Type toPrimitive(string s)
{
    import std.string;
    switch(s){
    case "void": return Primitives.Void;
    case "int": return Primitives.Int;
    case "char": return Primitives.Char;
    default: throw new Exception("Could not convert \"%s\" to primitive".format(s));
    }
}

class PrimitiveType : Type {
public:
    package enum Primitive {
        INT,
        VOID,
        CHAR
    };
    this(Primitive type)
    {
        this.type = type;
    }
    auto getType() pure
    {
        return this.type;
    }
    override void visit(TypeVisitor tv){ tv.invoke(this); }
    override string toString() const
    {
        import std.string;
        return "PrimitiveType(%s)".format(this.type);
    }
private:
    Primitive type;
};

enum Primitives {
    Int = new PrimitiveType(PrimitiveType.Primitive.INT),
    Void = new PrimitiveType(PrimitiveType.Primitive.VOID),
    Char = new PrimitiveType(PrimitiveType.Primitive.CHAR)
};

class FunctionType : Type {
public:
    this(Type ret, Type[] param)
    {
        this.return_type = ret;
        this.param_types = param;
    }

    override void visit(TypeVisitor tv){ tv.invoke(this); }

    auto returnType() pure
    {
        return this.return_type;
    }

    auto parameterTypes() pure
    {
        return this.param_types;
    }

    override string toString() const
    {
        import std.string;
        return "(%s -> %s)".format(this.param_types, this.return_type);
    }
private:
    Type return_type;
    Type[] param_types;
};
