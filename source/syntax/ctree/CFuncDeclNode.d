module syntax.ctree.CFuncDeclNode;

import syntax.ctree.CDeclarationNode;
import syntax.ctree.CBlockStatementNode;


struct CParameter {
    string type;
    string name;
};

class CFuncDeclNode : CDeclarationNode {
public:
    this(CStorageClass cl, string ret, string func_name, 
            CParameter[] params, CBlockStatementNode c)
    {
        super(cl);
        this.returnType = ret;
        this.name = func_name;
        this.parameters = params;
        this.child = c;
    }

    string returnType;
    string name;
    CParameter[] parameters;
    CBlockStatementNode child;
};
