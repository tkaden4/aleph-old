module syntax.tree.ProgramNode; 

import syntax.tree.ASTNode;
import syntax.tree.StatementNode;
import symbol.SymbolTable;

class ProgramNode : ASTNode {
public:
    this(StatementNode[] _children)
    {
        this._children = _children;
    }

    @property StatementNode[] children()
    {
        return this._children;
    }
public:
    SymbolTable globalTable;
private:
    StatementNode[] _children;
};
