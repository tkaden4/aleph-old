module syntax.tree.BlockNode;

import syntax.tree.ASTNode;
import syntax.tree.ExpressionNode;

import symbol.Type;

import std.range;

class BlockNode : ExpressionNode {
public:
    this(ExpressionNode[] children)
    {
        this._children = children;
    }

    invariant
    {
        assert(this._children);
    }

    override @property Type resultType()
    {
        return this.result_type;
    }

    @property void resultType(Type t)
    {
        this.result_type = t;
    }

    override string toString()
    {
        import std.string;
        return "BlockNode(%s)".format(this.children);
    }

    @property auto children()
    {
        return this._children;
    }

    @property void children(ExpressionNode[] nodes)
    {
        this._children = nodes;
    }
private:
    ExpressionNode[] _children;
    Type result_type;
};
