module parse.nodes.ASTPrinter;

import std.stdio;
import parse.nodes.ASTVisitor;

class ASTPrinter : ASTVisitor {
public:
    override void visitIntegerNode(IntegerNode node)
    {
        "%s%s".format(this.entab, node).writeln;
    }

    override void visitBlockNode(BlockNode node)
    {
        ++this.indent_level;
        foreach(child; node.getChildren){
            child.visit(this);
        }
        --this.indent_level;
    }

    override void visitProcDecl(ProcDeclNode node)
    {
        "%sProcedure %s :: %s -> %s"
            .format(this.entab, node.getName, node.getParams, node.getReturnType).writeln;
        node.getBody.visit(this);
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
