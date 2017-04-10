module semantics.symbol.Type;

public interface Type {
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

    override FunctionType asFunction(){ return null; }

    override string toString() const
    {
        import std.string;
        return "Primitive(%s)".format(this.type);
    }
private:
    Primitive type;
};


public class FunctionType : Type {
public:
    this(Type ret, Type[] param)
    {
        this.return_type = ret;
        this.param_types = param;
    }

    invariant
    {
        foreach(x; this.param_types){
            assert(x, "Param is null");
        }
        assert(this.return_type, "Return is null");
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

    override string toString()
    {
        import std.string;
        string params;
        foreach(i, x; this.param_types){
            if(i == this.param_types.length - 1){
                params ~= "%s".format(x);
                break;
            }
            params ~= "%s, ".format(x);
        }
        return "((%s) -> %s)".format(params, this.return_type);
    }
private:
    Type return_type;
    Type[] param_types;
};
