module parse.nodes.ProgramNode;

import parse.nodes.ASTNode;
import parse.nodes.StatementNode;

class ProgramNode : ASTNode {
    this(StatementNode[] _children)
    {
        this._children = _children;
    }

    override void visit(ASTVisitor vt){ vt.visitProgramNode(this); }

    @property StatementNode[] children()
    {
        return this._children;
    }
private:
    StatementNode[] _children;
};
