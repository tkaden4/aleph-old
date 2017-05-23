module syntax.visitors.DeclarationVisitor;

import syntax.tree.declaration;
import syntax.visitors.ExpressionVisitor;

public class DeclarationVisitor {
    alias NodeType = DeclarationNode;

    public DeclarationNode visit(DeclarationNode node)
    {
        import std.string;

        import util;
        import AlephException;

        auto visitor = new ExpressionVisitor;
        return node.match(
            (VarDeclNode node) => node.then!(x => node.initVal = visitor.visit(node.initVal)),
            (){ throw new AlephException("couldn't visit declaration %s".format(node)); }
        );
    }
}
