module semantics.ctype.CFunctionType;

import semantics.ctype.CType;

public class CFunctionType : CType {
    this(CType ret, CType[] params)
    {
        this.returnType = ret;
        this.parameterTypes = params;
    }

    CType returnType;
    CType[] parameterTypes;
};
