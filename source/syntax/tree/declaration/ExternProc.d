module syntax.tree.declaration.ExternProc;

import semantics.type;
import syntax.tree.expression.Statement;
import syntax.tree.declaration.Declaration;
import syntax.common.routine;

import util;
import std.string;

public class ExternProc : Declaration {

    this(string name, Type type, Type[] params, bool isvararg=false)
    {
        this.name = name;
        this.returnType = type;
        this.parameterTypes = params;
        this.isvararg = isvararg;
    }

    auto functionType()
    {
        return this.returnType.use!(k => new FunctionType(k, this.parameterTypes, this.isvararg));
    }

    override string toString() const
    {
        return "ExternProc(%s, ret: %s, params: %s, vararg: %s)".format(this.name,
                                                            this.returnType,
                                                            this.parameterTypes,
                                                            this.isvararg);
    }

    bool isvararg;
    string name;
    Type returnType;
    Type[] parameterTypes;
};
