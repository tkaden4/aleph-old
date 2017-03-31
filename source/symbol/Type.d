module symbol.Type;

interface Type {
    FunctionType asFunction();
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

    override FunctionType asFunction(){ return null; }

    override string toString() const
    {
        import std.string;
        return "Primitive(%s)".format(this.type);
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

    override FunctionType asFunction()
    {
        return this;
    }

    @property auto returnType()
    {
        return this.return_type;
    }

    @property auto parameterTypes()
    {
        return this.param_types;
    }

    @property void returnType(Type t)
    {
        this.return_type = t;
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
