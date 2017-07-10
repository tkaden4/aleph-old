module syntax.tree.declaration.VarDecl;

import syntax.tree.declaration.Declaration;
import syntax.tree.expression.Expression;

public class VarDecl : Declaration {
public:

    string name;
    Type type;
    Expression initVal;

    this(in string name, Type type, Expression init=null)
    {
        this.name = name;
        this.type = type;
        this.initVal = init;
    }

    override string toString() const
    {
        import std.string;
        return "VarDecl(%s, %s)".format(this.name, this.type);
    }
};
