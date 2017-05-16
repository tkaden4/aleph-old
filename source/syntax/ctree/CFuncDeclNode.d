module syntax.ctree.CFuncDeclNode;

import syntax.ctree.CDeclarationNode;
import syntax.ctree.CBlockStatementNode;
import semantics.ctype.CType;

import syntax.common.routine;

public struct CParameter {
    string name;
    CType type;
};

public class CFuncDeclNode: CDeclarationNode, CTopLevelNode {
    mixin routineNodeClass!(CType, CBlockStatementNode, CParameter);
    this(CStorageClass cl, CType ret, in string func_name, 
         CParameter[] params, CBlockStatementNode c)
    {
        super(cl);
        this.init(func_name, ret, params, c);
    }
};
