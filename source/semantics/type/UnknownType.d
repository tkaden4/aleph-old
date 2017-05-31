module semantics.type.UnknownType;

import semantics.type.Type;

public class UnknownType : Type {
    override bool canCast(Type o)
    in{
        assert(o);
    }body{
        return false;
    }

    override string toString() const
    {
        return "UnknownType()";
    }
};
