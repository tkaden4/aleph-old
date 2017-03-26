module parse.nodes.ExpressionNode;

public import parse.visitors.ASTVisitor;
public import parse.nodes.ASTNode;

public import symbol.Type;
public import std.typecons;

interface ExpressionNode : ASTNode {
    @property Type resultType();
};
