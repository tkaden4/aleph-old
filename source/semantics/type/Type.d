module semantics.type.Type;

public interface Type {
    bool canCast(Type other);
};

import util;
import AlephException;
import semantics.type;
import syntax.print;

import std.string;

public string toPrintable(Type t)
in {
    assert(t);
} body {
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
        (TypeofType u) => "typeof(%s)".format(u.node.toPretty(true)),
        (UnknownType _) => "[unresolved]",
        (){ throw new AlephException("%s cannot be converted to printable string".format(t)); }
    );
}
