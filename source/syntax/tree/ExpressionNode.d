module syntax.tree.ExpressionNode;

public import syntax.tree.ASTNode;
public import symbol.Type;
public import std.typecons;

interface ExpressionNode : ASTNode {
    @property Type resultType();
};
