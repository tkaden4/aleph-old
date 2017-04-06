module syntax.tree.VarDeclNode;

import syntax.tree.StatementNode;
import syntax.tree.ExpressionNode;

import symbol.Type;

class VarDeclNode : StatementNode {
public:
    this(string id, Type type, ExpressionNode exp)
    {
        this.name = id;
        this.type = type;
        this.init = exp;
    }

    override void visit(ASTVisitor tv){ tv.visitVarDecl(this); }

    override string toString() const
    {
        return "VarDecl(%s) :: %s".format(this.name, this.type);
    }

public:
    const(string) name;
    Type type;
    ExpressionNode init;
};
