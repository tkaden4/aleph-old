module syntax.ctree.visitors.CTreeVisitor;

public import syntax.ctree;

import std.string;
import std.range;
import std.algorithm;

import util.match;

class CTreeVisitor {
    protected final auto dispatch(CTreeNode node)
    {
        node.match(
            (CProgramNode n) => this.visit(n),
            (CStatementNode n) => this.visit(n),
            (CTreeNode n){ throw new CTreeException("Unable to visit %s".format(n)); }
        );
    }

    abstract void visit(CProgramNode node)
    {
        node.children.each!(x => this.dispatch(x));
    }

    abstract void visit(CStatementNode node);

    // TODO finish implementing
};
