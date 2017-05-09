module semantics.type.Type;

import semantics.type.PrimitiveType;

public interface Type {
    abstract bool canCast(Type other);
};

import util;
import semantics.type;

public string toPrintable(Type t)
{
    if(!t){
        return "nul";
    }
    return t.match(
        (PrimitiveType type) => type.primString,
        (PointerType type) => "*" ~ type.type.toPrintable,
        (QualifiedType type) => "const " ~ type.type.toPrintable,
        (FunctionType type) {
            string str = "(";
            type.parameterTypes.headLast!(x => str ~= x.toPrintable ~ ", ", x => str ~= x.toPrintable);
            str ~= ") -> " ~ type.returnType.toPrintable;
            return str;
        },
        (Type t) => "unknown type"
    );
}
