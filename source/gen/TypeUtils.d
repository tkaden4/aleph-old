module gen.TypeUtils;

import syntax.transform.CType;
import util;
private import std.string;

/*
public string typeString(CType type, string id)
{
    return type.match(
        (CPrimitive t) => t.typeString(id),
        (CFunctionType t) => t.typeString(id)
    );
}

private string typeString(CPrimitive t, string inner)
{
    return inner;
}

private string typeString(CFunctionType t, string inner)
{
    return inner;
}
*/

public string typeString(CType t, string id)
{
    import util;
    return t.use!(t => t.match((CPrimitive t) => "%s%s".format(t.name, (id.length == 0 ? "" : " " ~ id)),
                                   (CPointerType t) => t.type.typeString("*" ~ id),
                                   (CQualifiedType t){
                                       final switch(t.qualifier){
                                       case CTypeQualifier.Const: return t.type.typeString("const " ~ id);
                                       }
                                   },
                                   (CFunctionType t){
                                       string inside = "(*" ~ id ~ ")";
                                       inside ~= "(";
                                       t.parameterTypes.each!(
                                           x => inside ~= x.typeString("")
                                       );
                                       inside ~= ")";
                                       return t.returnType.typeString(inside);
                                   },
                                   (CType t) => null)).err(new Exception("Unknown type %s".format(t)));
}
