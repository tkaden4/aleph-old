module parse.nodes.ProcDeclNode;

import parse.nodes.ASTNode;
import parse.nodes.ExpressionNode;
import parse.nodes.StatementNode;

import symbol.Type;

import std.string;

struct Parameter {
    string id;
    Type type;

    string toString() const
    {
        return "Parameter(%s, %s)".format(this.id, this.type);
    }
};

class ProcDeclNode : StatementNode {
public:
    this(string id, Type ret, Parameter[] params, ExpressionNode exp)
    {
        this.id = id;
        this.ret_type = ret;
        this.params = params;
        this.exp = exp;
    }

    auto bodyNode()
    {
        return this.exp;
    }

    auto name()
    {
        return this.id;
    }

    auto parameters()
    {
        return this.params;
    }

    @property Type returnType()
    {
        return this.ret_type;
    }

    @property void returnType(Type type)
    {
        this.ret_type = type;
    }

    override void visit(ASTVisitor tv){ tv.visitProcDecl(this); }

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
