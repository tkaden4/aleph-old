module parse.nodes.ASTPrinter;

import std.stdio;
import parse.nodes.ASTVisitor;

class ASTPrinter : ASTVisitor {
public:
    override void visitBasic(ASTNode node)
    {
        "%sUnvisited node".format(this.entab).writeln;
    }

    override void visitProcDecl(ProcDeclNode node)
    {
        "%sProcedure %s :: %s -> %s"
            .format(this.entab, node.getName, node.getParams, node.getReturnType).writeln;
        ++this.indent_level;
        node.getBody.visit(this);
        --this.indent_level;
    }
private:
    string entab()
    {
        string res;
        for(size_t i = 0; i < this.indent_level; ++i){
            res ~= '\t';
        }
        return res;
    }
private:
    size_t indent_level = 0;
};
