module parse.nodes.VarDeclNode;

import parse.nodes.StatementNode;
import parse.nodes.ExpressionNode;
import symbol.Type;

class VarDeclNode : StatementNode {
public:
    this(string id, const(Type) type, ExpressionNode exp)
    {

    }

    override void visit(ASTVisitor tv){ tv.visitBasic(this); }
};
