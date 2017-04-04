module semantics.Sugar;

import symbol.SymbolTable;
import symbol.Type;
import parse.visitors.ResultVisitor;

ASTNode desugar(ASTNode node)
{
    return new Sugar(node).visit(node);
}

class Sugar : ResultVisitor!ASTNode {
    this(ASTNode node)
    {
        super(node);
    }
override:
    void visitProgramNode(ProgramNode node)
    {

    }
}
