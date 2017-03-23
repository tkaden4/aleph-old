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

    mixin basicNodeVisitImpl;

    override string toString()
    {
        import std.string;
        string paramstr;
        foreach(i, p; this.params){
            paramstr ~= "\n\t%s".format(p);
            if(i != this.params.length - 1){
                paramstr ~= ", ";
            }
        }
        return "ProcDeclNode(%s(%s)\n\t-> %s {\n%s\n})"
                    .format(this.id, paramstr, this.ret, this.exp);
    }
private:
    string id;
    Type ret;
    Parameter[] params;
    ASTNode exp;
};
