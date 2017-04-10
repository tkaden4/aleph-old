module syntax.tree.ExpressionNode;

public import syntax.tree.ASTNode;
public import semantics.symbol.Type;

public interface ExpressionNode : ASTNode {
    @property Type resultType();
};
