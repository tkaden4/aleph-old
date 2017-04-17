module syntax.ctree.CReturnNode;

import syntax.ctree.CStatementNode;
import syntax.ctree.CExpressionNode;

public class CReturnNode : CStatementNode {
    this(CExpressionNode exp)
    {
        this.exp = exp;
    }

    CExpressionNode exp;
};
