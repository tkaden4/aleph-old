module semantics.type.PointerType;

import semantics.type.Type;

public class PointerType : Type {
    this(Type to)
    {
        this.type = to;
    }

    invariant
    {
        assert(this.type);
    }

    override string toString() const
    {
        import std.format;
        return "PointerType(%s)".format(this.type);
    }

    override bool canCast(Type other)
    {
        import util;
        return other.match(
            (PointerType x) => x.type.canCast(this.type),
            (Type t) => false
        );
    }

    Type type;
};
