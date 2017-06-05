module syntax.tree.Program; 

import syntax.tree.declaration.Declaration;

public class Program {
public:
    this(Declaration[] _children)
    {
        this.children = _children;
    }

    Declaration[] children;
};
