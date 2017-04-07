module syntax.ctree.CBlockStatementNode;

import syntax.ctree.CStatementNode;

class CBlockStatementNode : CStatementNode {
public:
    this(CStatementNode[] substatements)
    {
        this.children = substatements;
    }

    invariant
    {
        import std.algorithm;
        import std.range;
        this.children.each!(x => assert(x));
    }

    CStatementNode[] children;
};
