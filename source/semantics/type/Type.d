module semantics.type.Type;

public interface Type {
    bool canCast(Type other);

    abstract string toString() const;
};

import util;
import semantics.type;

import std.string;

public string toPrintable(const(Type) t)
{
    import std.stdio;
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
        (TypeofType u) => "typeof(%s)".format(/*u.node.toPretty(true)*/"none"),
        (UnknownType _) => "[unresolved]",
        (){ throw new AlephException("%s cannot be converted to printable string".format(t)); }
    );
}
