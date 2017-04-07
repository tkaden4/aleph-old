module syntax.tree.ProgramNode; 

import syntax.tree.ASTNode;
import syntax.tree.StatementNode;

class ProgramNode : ASTNode {
    this(StatementNode[] _children)
    {
        this._children = _children;
    }

    @property StatementNode[] children()
    {
        return this._children;
    }
private:
    StatementNode[] _children;
};
