module syntax.ctree.CTypedefNode;

import syntax.ctree.CTreeNode;

class CTypedefNode : CTreeNode {
public:
    this(string ct, string tt)
    {
        this.ctype = ct;
        this.totype = tt;
    }

    override string toString() const
    {
        import std.string;
        return "Typedef(%s = %s)".format(this.totype, this.ctype);
    }

    string ctype;
    string totype;
};
