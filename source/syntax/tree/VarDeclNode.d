module syntax.tree.VarDeclNode;

import syntax.tree.StatementNode;
import syntax.tree.ExpressionNode;
import syntax.builders.variable;

public class VarDeclNode : StatementNode {
public:
    mixin variableClass!(Type, ExpressionNode);

    this(string name, Type type, ExpressionNode node)
    {
        this.initv(name, type, node);
    }

    override string toString() const
    {
        import std.string;
        return "VarDecl(%s, %s)".format(this.name, this.type);
    }
};
