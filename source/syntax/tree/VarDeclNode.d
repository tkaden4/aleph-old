module syntax.tree.VarDeclNode;

import syntax.tree.StatementNode;
import syntax.tree.ExpressionNode;

class VarDeclNode : StatementNode {
public:
    this(string id, Type type, ExpressionNode exp)
    {
        this.name = id;
        this.type = type;
        this.init = exp;
    }

    override string toString() const
    {
        import std.string;
        return "VarDecl(%s) :: %s".format(this.name, this.type);
    }

public:
    const(string) name;
    Type type;
    ExpressionNode init;
};
