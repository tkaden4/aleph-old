module syntax.tree.visitors.ASTPrinter;

import std.stdio;
import syntax.tree.visitors.ASTVisitor;

auto printTree(ASTNode node)
{
    node.visit(new ASTPrinter);
    return node;
}

class ASTPrinter : ASTVisitor {
public override{
    void visitIntegerNode(IntegerNode node)
    {
        "%s%s".writefln(this.entab, node);
    }

    void visitReturnNode(ReturnNode node)
    {
        "%sReturn(%s)".writefln(this.entab, node.value);
    }

    void visitCharNode(CharNode node)
    {
        "%s%s".writefln(this.entab, node);
    }

    void visitProgramNode(ProgramNode node)
    {
        foreach(x; node.children){
            x.visit(this);
        }
    }

    void visitCallNode(CallNode node)
    {
        "%sCall(".writefln(this.entab);
        ++this.indent_level;
        node.toCall.visit(this);
        foreach(x; node.arguments){
            x.visit(this);
        }
        --this.indent_level;
        "%s)".writefln(this.entab);
    }

    void visitBlockNode(BlockNode node)
    {
        if(node.children.length){
            "%sBlock(".writefln(this.entab);
            ++this.indent_level;
            foreach(child; node.children){
                child.visit(this);
            }
            --this.indent_level;
            "%s)".writefln(this.entab);
        }else{
            "%sBlock()".writefln(this.entab);
        }
    }

    void visitProcDecl(ProcDeclNode node)
    {
        "%sProc %s :: %s -> %s("
            .writefln(this.entab, node.name, node.parameters, node.returnType);
        ++this.indent_level;
        node.bodyNode.visit(this);
        --this.indent_level;
        ")".writeln;
    }

    void visitIdentifierNode(IdentifierNode node)
    {
        "%s%s :: %s".writefln(this.entab, node, node.resultType);
    }

    void visitVarDecl(VarDeclNode node)
    {
        "%s%s".writefln(this.entab, node);
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
