module syntax.tree.expression.ExpressionNode;

public import syntax.tree.ASTNode;
public import semantics.type;

public interface ExpressionNode : ASTNode {
    @property Type resultType();
};
