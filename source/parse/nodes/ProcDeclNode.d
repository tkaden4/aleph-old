module parse.nodes.ProcDeclNode;

import parse.nodes.ASTNode;
import parse.nodes.ASTVisitor;
import parse.symbol.Type;

import std.string;

struct Parameter {
    string id;
    Type type;
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

    mixin basicNodeVisitImpl;

    override string toString()
    {
        import std.string;
        string paramstr;
        foreach(p; this.params){
            paramstr ~= "%s:%s, ".format(p.id, p.type);
        }
        return "ProcDeclNode(%s(%s) -> %s = %s)"
                    .format(this.id, paramstr, this.ret, this.exp);
    }
private:
    string id;
    Type ret;
    Parameter[] params;
    ASTNode exp;
};
