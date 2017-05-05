module syntax.ctree.CTypedefNode;

import syntax.ctree.CStatementNode;
import syntax.transform.CType;

class CTypedefNode : CStatementNode {
public:
    this(CType ct, in string tt)
    {
        this.ctype = ct;
        this.totype = tt;
    }

    override string toString() const
    {
        import std.string;
        return "Typedef(%s = %s)".format(this.totype, this.ctype);
    }

    CType ctype;
    string totype;
};
