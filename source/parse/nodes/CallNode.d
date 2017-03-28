module parse.nodes.CallNode;

import parse.nodes.ExpressionNode;

class CallNode : ExpressionNode {
    this(ExpressionNode toCall, ExpressionNode[] args)
    {
        this.call = toCall;
        this.args = args;
    }

    invariant
    {
        assert(this.call !is null, "tocall is null");
    }

    override void visit(ASTVisitor tv){ tv.visitCallNode(this); }

    @property ExpressionNode toCall()
    {
        return this.call;
    }

    @property ExpressionNode[] arguments()
    {
        return this.args;
    }

    override @property Type resultType()
    {
        if(!this.result_type){
            /* TODO this is where the error occurs */
            auto k = this.call.resultType;
            if(k){
                k = k.asFunction;
            }
            this.result_type = k;
        }
        return this.result_type;
    }

    @property void resultType(Type t)
    {
        this.result_type = t;
    }
private:
    Type result_type;
    ExpressionNode call;
    ExpressionNode[] args;
};
