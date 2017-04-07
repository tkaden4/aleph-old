module syntax.transform;

import syntax.tree.visitors.ASTVisitor;

import syntax.ctree;
import syntax.tree.ProgramNode;

/* Transform the Aleph AST into the C AST, for 
 * improved error checking and code generation */

public auto transform(ProgramNode node)
{
    return new ASTTransformer().visit(node);
}

private class ASTTransformer : ASTVisitor {
    alias visit = ASTVisitor.visit;
public:
    CProgramNode result;

    CProgramNode visit(ASTNode node)
    {
        this.dispatch(node);
        return this.result;
    }
};
