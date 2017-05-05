module gen.TypeUtils;

private import std.string;

import syntax.transform.CType;
import util;

public string typeString(CType t, string id)
{
    return t.use!(t => t.match((CPrimitive t) => t.typeString(id),
                               (CPointerType t) => t.typeString(id),
                               (CQualifiedType t) => t.typeString(id),
                               (CFunctionType t) => t.typeString(id),
                               (CType t) => null)).err(new Exception("Unknown type %s".format(t)));
}

private string typeString(CPrimitive t, string inner)
{
    return "%s%s".format(t.name, (inner.length == 0 ? "" : " " ~ inner));
}

private string typeString(CFunctionType t, string inner)
{
    string inside = "(*" ~ inner ~ ")";
    inside ~= "(";
    t.parameterTypes.each!(
        x => inside ~= x.typeString("")
    );
    inside ~= ")";
    return t.returnType.typeString(inside);
}

private string typeString(CPointerType t, string inner)
{
    return t.type.typeString("*" ~ inner);
}

private string typeString(CQualifiedType t, string inner)
{
    final switch(t.qualifier){
    case CTypeQualifier.Const: return t.type.typeString("const " ~ inner);
    }
}
