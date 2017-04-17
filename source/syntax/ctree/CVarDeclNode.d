module syntax.ctree.CVarDeclNode;

import syntax.ctree.CStatementNode;
import syntax.ctree.CDeclarationNode;
import syntax.ctree.CExpressionNode;
import syntax.transform.CType;

public class CVarDeclNode : CDeclarationNode {
    this(CStorageClass sc, CType type, string id, CExpressionNode init=null)
    {
        super(sc);
        this.type = type;
        this.name = id;
        this.init = init;
    }
    CType type;
    string name;
    CExpressionNode init;
};
