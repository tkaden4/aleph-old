module syntax.tree.ProgramNode; 

import syntax.tree.ASTNode;
import syntax.tree.declaration.DeclarationNode;

public class ProgramNode : ASTNode {
public:
    this(DeclarationNode[] _children)
    {
        this.children = _children;
    }

    DeclarationNode[] children;
};
