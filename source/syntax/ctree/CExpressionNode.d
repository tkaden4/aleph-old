module syntax.ctree.CExpressionNode;

import syntax.ctree.CStatementNode;
public import syntax.transform.CType;

public interface CExpressionNode : CStatementNode {
    @property CType type();
};
