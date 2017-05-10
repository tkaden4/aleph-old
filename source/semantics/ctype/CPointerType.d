module semantics.ctype.CPointerType;

import semantics.ctype.CType;

public class CPointerType : CType {
    this(CType type)
    {
        this.type = type;
    }
    CType type;
};

