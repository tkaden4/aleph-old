module syntax.builder.AlephTreeBuilder;

import syntax.tree;
import semantics;
import util;

public class AlephTreebuilder {
    ASTNode node;

    const(ProcDeclNode) procedure(string name, Type returnType)
    {
        return new ProcDeclNode(name, returnType, null, null);
    }

    auto variable()
    {
    
    }
};
