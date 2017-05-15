module syntax.tree.declaration.ProcDeclNode;

import syntax.tree.ASTNode;
import syntax.tree.ReturnNode;
import syntax.tree.expression.ExpressionNode;
import syntax.tree.expression.StatementNode;

import semantics.type : Type, FunctionType;
import syntax.common.routine;

import std.string;
import std.range;
import std.algorithm;
import util;

public alias Parameter = ProcDeclNode.Parameter;
public class ProcDeclNode : StatementNode {

    mixin routineNodeClass!(Type, ExpressionNode);

    this(in string name, Type type, Parameter[] params, ExpressionNode init=null)
    {
        this.init(name, type, params, init);
    }

    auto functionType()
    {
        return new FunctionType(this.returnType, this.parameters.map!(x => x.type).array);
    }

    override string toString() const
    {
        return "Procedure(name: %s, ret: %s, params: %s)".format(this.name, this.returnType, this.parameters.map!(x => x.type).array);
    }
};
