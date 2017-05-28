module syntax.tree.expression.IfExpression;

import syntax.tree.expression.Expression;

public class IfExpression : Expression {
    this(Expression ifn, Expression then, Expression elsen, Type res)
    {
        super(res);
        this.ifexp = ifn;
        this.thenexp = then;
        this.elseexp = elsen;
    }

    override string toString() const
    {
        import std.string;
        return "IfNode(%s, %s%s)".format(this.ifexp,
                                         this.thenexp,
                                         this.elseexp ? 
                                            ", %s".format(this.elseexp) :
                                            "");
    }

    Expression ifexp;
    Expression thenexp;
    Expression elseexp;
};
