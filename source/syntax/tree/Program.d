module syntax.tree.Program; 

import syntax.tree.ASTNode;
import syntax.tree.declaration.Declaration;

public class Program : ASTNode {
public:
    this(Declaration[] _children)
    {
        this.children = _children;
    }

    Declaration[] children;
};
