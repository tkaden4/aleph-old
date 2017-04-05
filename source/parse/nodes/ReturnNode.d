module parse.nodes.ReturnNode;

import parse.nodes.StatementNode;

class ReturnNode : StatementNode {
public:
    this(ExpressionNode v)
    {
        this._value = v;
    }

    @property auto value()
    {
        return this._value;
    }
override void visit(ASTVisitor tv){ tv.visitReturnNode(this); }
private:
    ExpressionNode _value;
};
