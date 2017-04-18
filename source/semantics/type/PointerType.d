module semantics.type.PointerType;

import semantics.type.Type;

public class PointerType : Type {
    this(Type to)
    {
        this.type = to;
    }

    override string toString() const
    {
        import std.format;
        return "PointerType(%s)".format(this.type);
    }

    Type type;
};
