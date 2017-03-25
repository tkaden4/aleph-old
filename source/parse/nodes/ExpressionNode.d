module parse.nodes.ExpressionNode;

import parse.nodes.ASTNode;
import parse.nodes.ASTVisitor;
public import symbol.Type;

interface ExpressionNode : ASTNode {
    bool hasResult() const;
    const(Type) getResultType() const;
};
