module syntax.tree.ExternProcNode;

import syntax.builders.routine;
import semantics.type;

import syntax.tree.StatementNode;

import util;
import std.string;

public class ExternProcNode : StatementNode {
    this(string name, Type type, Type[] params)
    {
        this.name = name;
        this.returnType = type;
        this.parameterTypes = params;
    }

    auto functionType()
    {
        return this.returnType.use!(k => new FunctionType(k, this.parameterTypes));
    }

    override string toString() const
    {
        return "ExternProc(%s, ret: %s, params: %s)".format(this.name,
                                                            this.returnType,
                                                            this.parameterTypes);
    }

    string name;
    Type returnType;
    Type[] parameterTypes;
};
