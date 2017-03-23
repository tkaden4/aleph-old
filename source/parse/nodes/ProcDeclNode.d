module parse.nodes.ProcDeclNode;

import parse.nodes.ASTNode;
import parse.nodes.ASTVisitor;
import parse.symbol.Type;

import std.string;

struct Parameter {
    string id;
    Type type;

    string toString() const
    {
        return "Parameter(%s, %s)".format(this.id, this.type);
    }
};

class ProcDeclNode : ASTNode {
public:
    this(string id, Type ret, Parameter[] params, ASTNode exp)
    {
        this.id = id;
        this.ret = ret;
        this.params = params;
        this.exp = exp;
    }

    auto getBody()
    {
        return this.exp;
    }

    auto getName()
    {
        return this.id;
    }

    auto getParams()
    {
        return this.params;
    }

    auto getReturnType()
    {
        return this.ret;
    }

    override void visit(ASTVisitor tv){ tv.visitProcDecl(this); }

    override string toString()
    {
        import std.string;
        return "ProcDeclNode(%s(%s) -> %s = %s)"
                    .format(this.id, this.params, this.ret, this.exp);
    }
private:
    string id;
    Type ret;
    Parameter[] params;
    ASTNode exp;
};
