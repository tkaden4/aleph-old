module parse.nodes.ASTNode;

import parse.nodes.ASTVisitor;

/* Currently, this is all we need */
class ASTNode {
    abstract void visit(ASTVisitor visitor);
};
