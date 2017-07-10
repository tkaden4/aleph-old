module syntax.tree.declaration.ProcDecl;

import syntax.tree.Return;
import syntax.tree.Parameter;
import syntax.tree.expression.Expression;
import syntax.tree.declaration.Declaration;

import semantics.type : Type, FunctionType;

import std.string;
import std.range;
import std.algorithm;
import util;

public class ProcDecl : Declaration {

    string name;
    Type returnType;
    Parameter[] parameters;
    Expression bodyNode;

    this(in string name, Type type, Parameter[] params, Expression init=null)
    {
        this.name = name;
        this.returnType = type;
        this.parameters = params;
        this.bodyNode = init;
    }

    auto functionType()
    {
        return new FunctionType(this.returnType, this.parameters.map!(x => x.type).array);
    }

    override string toString() const
    {
        return "Procedure(name: %s, ret: %s, params: %s)"
                    .format(this.name, this.returnType, this.parameters.map!"a.type".array);
    }
};
