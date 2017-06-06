module syntax.tree.expression.StructInit;

import syntax.tree.expression;

public struct ParamInit {
    string name;
    Expression value;
};

public class StructInit : Expression {
    this(string name, ParamInit[] params, Type resultType)
    {
        super(resultType);
        this.name = name;
        this.inits = params;
    }

    override string toString() const
    {
        import std.string;
        return "StructInit(%s, %s)".format(this.name, this.inits);
    }
    
    string name;
    ParamInit[] inits;
};
