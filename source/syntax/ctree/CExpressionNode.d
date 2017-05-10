module syntax.ctree.CExpressionNode;

import syntax.ctree.CStatementNode;
public import semantics.ctype.CType;

public interface CExpressionNode : CStatementNode {
    @property CType type();
};
