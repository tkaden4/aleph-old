module gen.GenVisitor;

import std.file;
import std.stdio;

import parse.visitors.ASTVisitor;

import symbol.SymbolTable;

import gen.GenUtils;

final class GenVisitor : ASTVisitor {
private:
    import std.conv;
    File *output;
    SymbolTable table;
private:
    void visitParameters(ProcDeclNode node)
    {
        foreach(i, x; node.parameters){
            this.output.writef("%s %s", x.type.toCtype, x.name);
            if(i < node.parameters.length - 1){
                this.output.write(", ");
            }
        }
    }
public:
    this(SymbolTable table, ref File output)
    {
        this(table, &output);
    }

    this(SymbolTable table, File *output)
    {
        this.table = table;
        this.output = output;
    }
override:
    void visitProgramNode(ProgramNode node)
    {
        foreach(x; node.children){
            x.visit(this);
        }
    }

    void visitProcDecl(ProcDeclNode node)
    {
        this.output.writef(
                "%s %s(",
                node.returnType.toCtype,
                node.name
            );
        this.visitParameters(node);
        this.output.write(')');
        this.output.writeln("{");
        node.bodyNode.visit(this);
        this.output.writeln("}");
    }

    void visitCallNode(CallNode node)
    {
        node.toCall.visit(this);
    }

    void visitBlockNode(BlockNode node)
    {
        import std.range;
        auto back = node.children.back;
        if(back && back.resultType){
        }
        foreach(x; node.children){
            x.visit(this);
        }
    }

    void visitIdentifierNode(IdentifierNode node)
    {
    }

    void visitIntegerNode(IntegerNode node)
    {
    }

    void visitCharNode(CharNode node)
    {
    }
};
