module parse.symbol.Type;

interface TypeVisitor {
    void invoke(Type t);
};

interface Type {
    void visit(TypeVisitor tv);
};

class PrimitiveType : Type {
public:
    enum Primitive {
        INT,
        VOID
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
    Void = new PrimitiveType(PrimitiveType.Primitive.VOID)
};

class FunctionType : Type {
public:
    override void visit(TypeVisitor tv){ tv.invoke(this); }
    auto getReturnType() pure
    {
        return this.return_type;
    }
    auto getParameterTypes() pure
    {
        return this.param_types;
    }
private:
    Type return_type;
    Type[] param_types;
};
