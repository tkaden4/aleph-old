module syntax.tree.BlockNode;

import syntax.tree.ASTNode;
import syntax.tree.ExpressionNode;

import std.range;
import util;

class BlockNode : ExpressionNode {
public:
    this(ExpressionNode[] children)
    {
        this._children = children;
        this.result_type = this._children.use!(
            x => x.back.use!(
                x => x.resultType
            )
        ).or(Primitives.Void);
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
