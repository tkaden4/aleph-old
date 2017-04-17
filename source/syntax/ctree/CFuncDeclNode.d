module syntax.ctree.CFuncDeclNode;

import syntax.ctree.CDeclarationNode;
import syntax.ctree.CBlockStatementNode;
import syntax.transform.CType;

struct CParameter {
    CType type;
    string name;
};

class CFuncDeclNode : CDeclarationNode, CTopLevelNode {
public:
    this(CStorageClass cl, CType ret, string func_name, 
            CParameter[] params, CBlockStatementNode c)
    {
        super(cl);
        this.returnType = ret;
        this.name = func_name;
        this.parameters = params;
        this.bodyNode = c;
    }

    CType returnType;
    string name;
    CParameter[] parameters;
    CBlockStatementNode bodyNode;
};
