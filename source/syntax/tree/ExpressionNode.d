module syntax.tree.ExpressionNode;

public import syntax.tree.ASTNode;
public import semantics.symbol.Type;

interface ExpressionNode : ASTNode {
    @property Type resultType();
};
