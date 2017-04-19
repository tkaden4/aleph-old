module syntax.ctree.CExternFuncNode;

import syntax.ctree.CTopLevelNode;

import syntax.transform.CType;

public class CExternFuncNode : CTopLevelNode {
    this(string name, CType ret, CType[] types)
    {
        this.name = name;
        this.returnType = ret;
        this.parameterTypes = types;
    }

    string name;
    CType returnType;
    CType[] parameterTypes;
};
