module parse.nodes.VarDeclNode;

import parse.nodes.StatementNode;
import parse.nodes.ExpressionNode;
import symbol.Type;

class VarDeclNode : StatementNode {
public:
    this(string id, Type type, ExpressionNode exp)
    {
        this.id = id;
        this.type = type;
        this.init = exp;
    }

    override void visit(ASTVisitor tv){ tv.visitVarDecl(this); }

    @property string name() const
    {
        return this.id;
    }

    override string toString() const
    {
        return "VarDecl(%s) :: %s".format(this.id, this.type);
    }
public:
    const(string) id;
    Type type;
    ExpressionNode init;
};
