module parse.nodes.ASTNode;

public import parse.visitors.ASTVisitor;

/* TODO add immutable nodes / visitation pipeline */

/* Currently, this is all we need,
 * all an ASTNode needs is a way to 
 * call the correct method in a visitor */
interface ASTNode {
    void visit(ASTVisitor visitor);
};
