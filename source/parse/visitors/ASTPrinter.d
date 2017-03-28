module parse.visitors.ASTPrinter;

import std.stdio;
import parse.visitors.ASTVisitor;

class ASTPrinter : ASTVisitor {
public override{
    void visitIntegerNode(IntegerNode node)
    {
        "%s%s".format(this.entab, node).writeln;
    }

    void visitCharNode(CharNode node)
    {
        "%s%s".format(this.entab, node).writeln;
    }

    void visitProgramNode(ProgramNode node)
    {
        foreach(x; node.children){
            x.visit(this);
        }
    }

    void visitCallNode(CallNode node)
    {
        "%sCall(".format(this.entab).writeln;
        ++this.indent_level;
        node.toCall.visit(this);
        foreach(x; node.arguments){
            x.visit(this);
        }
        --this.indent_level;
        "%s)".format(this.entab).writeln;
    }

    void visitBlockNode(BlockNode node)
    {
        if(node.children.length){
            "%sBlock(".format(this.entab).writeln;
            ++this.indent_level;
            foreach(child; node.children){
                child.visit(this);
            }
            --this.indent_level;
            "%s)".format(this.entab).writeln;
        }else{
            "%sBlock()".format(this.entab).writeln;
        }
    }

    void visitProcDecl(ProcDeclNode node)
    {
        "%sProc %s :: %s -> %s("
            .format(this.entab, node.name, node.parameters, node.returnType).writeln;
        ++this.indent_level;
        node.bodyNode.visit(this);
        --this.indent_level;
        ")".writeln;
    }

    void visitIdentifierNode(IdentifierNode node)
    {
        "%s%s :: %s".format(this.entab, node, node.resultType).writeln;
    }

    void visitVarDecl(VarDeclNode node)
    {
        "%s%s".format(this.entab, node).write;
        if(node.init){
            " = ".writeln;
            ++this.indent_level;
            node.init.visit(this);
            --this.indent_level;
        }else{
            writeln();
        }
    }
}
private:
    string entab() pure
    {
        string res;
        for(size_t i = 0; i < this.indent_level; ++i){
            res ~= "  ";
        }
        return res;
    }
private:
    size_t indent_level = 0;
};
