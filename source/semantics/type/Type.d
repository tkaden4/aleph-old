module semantics.type.Type;

import semantics.type.PrimitiveType;

public interface Type {
    abstract bool canCast(Type other);
};

public PrimitiveType toPrimitive(string s)
{
    import std.string;
    switch(s){
    case "void": return Primitives.Void;
    case "int": return Primitives.Int;
    case "char": return Primitives.Char;
    default: throw new Exception("Could not convert \"%s\" to primitive".format(s));
    }
}
