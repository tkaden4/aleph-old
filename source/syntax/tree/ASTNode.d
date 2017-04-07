module syntax.tree.ASTNode;

public import syntax.tree.visitors.ASTVisitor;

/* TODO add immutable nodes / visitation pipeline */

/* Currently, this is all we need,
 * all an ASTNode needs is a way to 
 * call the correct method in a visitor */
public interface ASTNode {
};
