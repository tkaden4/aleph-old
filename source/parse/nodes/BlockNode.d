module parse.nodes.BlockNode;

import parse.nodes.ASTVisitor;
import parse.nodes.ASTNode;
import parse.nodes.ExpressionNode;
import parse.symbol.Type;

import std.range;

class BlockNode : ExpressionNode {
public:
    this(ExpressionNode[] children)
    {
        this.children = children;
    }

    invariant
    {
        assert(this.children !is null);
    }

    mixin basicNodeVisitImpl;

    auto getChildren()
    {
        return this.children;
    }

    override bool hasResult() const
    {
        return this.children.empty ?
                    false :
                    this.children.back.hasResult;
    }

    override const(Type) getResultType() const
    {
        return this.children.empty ?
                    Primitives.Void :
                    this.children.back.getResultType;
    }

    override string toString() const
    {
        import std.string;
        string str;
        foreach(i,p; this.children){
            str ~= "%s".format(p);
            if(i != this.children.length - 1){
                str ~= '\n';
            }
        }
        return "BlockNode(%s)".format(str);
    }
private:
    ExpressionNode[] children;
};
