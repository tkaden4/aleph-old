module syntax.ctree.CFuncDeclNode;

import syntax.ctree.CDeclarationNode;
import syntax.ctree.CBlockStatementNode;
import syntax.transform.CType;

import syntax.builders.routine;

public alias CParameter = CFuncDeclNode.Parameter;
public class CFuncDeclNode: CDeclarationNode, CTopLevelNode {
    mixin routineNodeClass!(CType, CBlockStatementNode);
    this(CStorageClass cl, CType ret, in string func_name, 
         CParameter[] params, CBlockStatementNode c)
    {
        super(cl);
        this.init(func_name, ret, params, c);
    }
};
