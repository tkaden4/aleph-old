module parse.nodes.ASTVisitor;

import std.string;

import parse.nodes.ASTException;
import parse.nodes.ASTNode;

class ASTVisitor {
    abstract void invoke(ASTNode node)
    {
        throw new ASTException("Unable to visit node:\n\t".format(node));
    }
};
