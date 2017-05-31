module gen.TypeUtils;

import std.string;
import std.algorithm;

import semantics.type;
import util;

public string typeString(Type t, in string id)
{
    return t.use!(t => t.match((PrimitiveType t) => t.typeString(id),
                               (PointerType t)   => t.typeString(id),
                               (QualifiedType t) => t.typeString(id),
                               (FunctionType t)  => t.typeString(id),
                               (Type t) => null)).err(new Exception("Unknown type %s".format(t)));
}

private string typeString(PrimitiveType t, in string inner)
{
    return "%s%s".format(t.primString, (inner.length == 0 ? "" : " " ~ inner));
}

private string typeString(FunctionType t, in string inner)
{
    string inside = "(*" ~ inner ~ ")";
    inside ~= "(";
    t.parameterTypes.headLast!(
        x => inside ~= x.typeString("") ~ ", ",
        x => inside ~= x.typeString("")
    );
    inside ~= ")";
    return t.returnType.typeString(inside);
}

private string typeString(PointerType t, in string inner)
{
    return t.type.typeString("*" ~ inner);
}

private string typeString(QualifiedType t, in string inner)
{
    final switch(t.qualifier){
    case TypeQualifier.Const: return t.type.typeString("const " ~ inner);
    }
}
