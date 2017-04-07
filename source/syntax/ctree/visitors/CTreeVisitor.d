module syntax.ctree.visitors.CTreeVisitor;

public import syntax.ctree;

import util.match;
import std.exception;
import std.string;
import std.range;
import std.algorithm;

class CTreeException : Exception { mixin basicExceptionCtors; };

class CTreeVisitor {
    final auto dispatch(CTreeNode node)
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
};
