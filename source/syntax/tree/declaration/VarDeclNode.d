module syntax.tree.declaration.VarDeclNode;

import syntax.tree.declaration.DeclarationNode;
import syntax.tree.expression.ExpressionNode;
import syntax.common.variable;

public class VarDeclNode : DeclarationNode {
public:
    mixin variableClass!(Type, ExpressionNode);

    this(in string name, Type type, ExpressionNode node)
    {
        this.initv(name, type, node);
    }

    override string toString() const
    {
        import std.string;
        return "VarDecl(%s, %s)".format(this.name, this.type);
    }
};
