module syntax.ctree.CExternFuncNode;

import syntax.ctree.CTopLevelNode;

import syntax.transform.CType;

public class CExternFuncNode : CTopLevelNode {
    this(string name, CType ret, CType[] types, bool vararg=false)
    {
        this.name = name;
        this.returnType = ret;
        this.parameterTypes = types;
        this.isVararg = vararg;
    }

    bool isVararg;
    string name;
    CType returnType;
    CType[] parameterTypes;
};
