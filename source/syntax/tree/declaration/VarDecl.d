module syntax.tree.declaration.VarDecl;

import syntax.tree.declaration.Declaration;
import syntax.tree.expression.Expression;
import syntax.common.variable;

public class VarDecl : Declaration {
public:
    mixin variableClass!(Type, Expression);

    this(in string name, Type type, Expression init=null)
    {
        this.initv(name, type, init);
    }

    override string toString() const
    {
        import std.string;
        return "VarDecl(%s, %s)".format(this.name, this.type);
    }
};
