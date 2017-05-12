module gen.TypeUtils;

import std.string;
import std.algorithm;

import semantics.ctype;
import util;

public string typeString(CType t, in string id)
{
    return t.use!(t => t.match((CPrimitiveType t) => t.typeString(id),
                               (CPointerType t) => t.typeString(id),
                               (CQualifiedType t) => t.typeString(id),
                               (CFunctionType t) => t.typeString(id),
                               (CType t) => null)).err(new Exception("Unknown type %s".format(t)));
}

private string typeString(CPrimitiveType t, in string inner)
{
    return "%s%s".format(t.name, (inner.length == 0 ? "" : " " ~ inner));
}

private string typeString(CFunctionType t, in string inner)
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

private string typeString(CPointerType t, in string inner)
{
    return t.type.typeString("*" ~ inner);
}

private string typeString(CQualifiedType t, in string inner)
{
    final switch(t.qualifier){
    case CTypeQualifier.Const: return t.type.typeString("const " ~ inner);
    }
}
