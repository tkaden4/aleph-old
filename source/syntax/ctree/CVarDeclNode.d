module syntax.ctree.CVarDeclNode;

import syntax.ctree.CStatementNode;
import syntax.ctree.CDeclarationNode;
import syntax.ctree.CExpressionNode;
import syntax.builders.variable;
import semantics.ctype.CType;

public class CVarDeclNode : CDeclarationNode {
    mixin variableClass!(CType, CExpressionNode);
    this(CStorageClass sc, CType type, in string id, CExpressionNode init=null)
    {
        super(sc);
        this.initv(id, type, init);
    }
};
