module semantics.type.PointerType;

import semantics.type.Type;

public class PointerType : Type {
    this(Type to)
    {
        this.type = to;
    }
    Type type;
};
