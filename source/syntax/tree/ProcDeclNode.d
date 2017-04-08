module syntax.tree.ProcDeclNode;

import syntax.tree.ASTNode;
import syntax.tree.ExpressionNode;
import syntax.tree.StatementNode;
import syntax.tree.ReturnNode;

import semantics.symbol.Type;

import std.string;

struct Parameter {
    string name;
    Type type;

    string toString() const
    {
        return "Parameter(%s, %s)".format(this.name, this.type);
    }
};

/* A quick note :
 * the return node is included in the body node */

class ProcDeclNode : StatementNode {
public:
    this(string id, Type ret, Parameter[] params, ExpressionNode exp)
    {
        this.id = id;
        this.ret_type = ret;
        this.params = params;
        this.exp = exp;
    }

    invariant
    {
        assert(this.id, "Null id in ProcDeclNode");
        assert(this.exp, "Null exp in ProcDeclNode");
    }

    @property auto bodyNode()
    {
        return this.exp;
    }

    @property void bodyNode(ExpressionNode node)
    {
        this.exp = node;
    }

    auto name()
    {
        return this.id;
    }

    auto parameters()
    {
        return this.params;
    }

    auto functionType()
    {
        import std.range;
        import std.algorithm;
        auto paramTypes = this.parameters.map!((x) => x.type).array;
        return new FunctionType(this.returnType, paramTypes);
    }

    @property Type returnType()
    {
        return this.ret_type;
    }

    @property void returnType(Type type)
    {
        this.ret_type = type;
    }

    override string toString()
    {
        import std.string;
        return "ProcDeclNode(%s(%s) -> %s = %s)"
                    .format(this.id, this.params, this.ret_type, this.exp);
    }
public:
    const(string) id;

    Type ret_type;

    Parameter[] params;
    ExpressionNode exp;
};
