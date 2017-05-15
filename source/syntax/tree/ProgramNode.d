module syntax.tree.ProgramNode; 

import syntax.tree.ASTNode;
import syntax.tree.expression.StatementNode;

public class ProgramNode : ASTNode {
public:
    this(StatementNode[] _children)
    {
        this.children = _children;
    }

    StatementNode[] children;
};
