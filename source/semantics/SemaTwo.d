module semantics.SemaTwo;

import syntax.tree.visitors.ASTVisitor;

/* Moves certain parts of the tree into lists
 * to later be used in generation/translation */

auto collect(ProgramNode node)
{
    return new SemaTwo().apply(node);
}

class SemaTwo : ASTVisitor {
public:
    ProgramNode result;
    auto apply(ProgramNode node)
    {
        this.dispatch(node);
        return this.result;
    }
override:
    void visit(ProgramNode node)
    {

    }
};
