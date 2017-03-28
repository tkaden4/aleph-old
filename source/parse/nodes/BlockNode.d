module parse.nodes.BlockNode;

import parse.nodes.ASTNode;
import parse.nodes.ExpressionNode;

import symbol.Type;

import std.range;

class BlockNode : ExpressionNode {
public:
    this(ExpressionNode[] children)
    {
        this._children = children;
        this.result_type = !this.children.empty ? Primitives.Void :
                                this.children.back.resultType;
    }

    invariant
    {
        assert(this._children);
    }

    override void visit(ASTVisitor tv){ tv.visitBlockNode(this); }

    void resolveType()
    {
        this.result_type = this.children.empty ? Primitives.Void 
                                               : this.children.back.resultType;
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

    @property ExpressionNode[] children()
    {
        return this._children;
    }
private:
    ExpressionNode[] _children;
    Type result_type;
};
