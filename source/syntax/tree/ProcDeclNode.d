module syntax.tree.ProcDeclNode;

import syntax.tree.ASTNode;
import syntax.tree.ExpressionNode;
import syntax.tree.StatementNode;
import syntax.tree.ReturnNode;

import semantics.type : Type, FunctionType;
import syntax.builders.routine;

import std.string;
import std.range;
import std.algorithm;
import util;

alias Parameter = ProcDeclNode.Parameter;
public class ProcDeclNode : StatementNode {
    mixin routineNodeClass!(Type, ExpressionNode);
    this(string name, Type type, Parameter[] params, ExpressionNode init=null)
    {
        this.init(name, type, params, init);
    }

    auto functionType()
    {
        import std.stdio;
        return this.returnType.use!(k => new FunctionType(k, this.parameters.map!(x => x.type).array)).then!(x => x.writeln);
    }
};
