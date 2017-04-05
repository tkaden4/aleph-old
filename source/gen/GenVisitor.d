module gen.GenVisitor;

import std.file;
import stdio = std.stdio;
import std.range;
import std.conv;

import parse.visitors.ResultVisitor;
import symbol.SymbolTable;
import gen.GenUtils;
public import gen.OutputBuilder;

auto generate(SymbolTable table, ASTNode node, OutputStream outp)
{
    return new GenVisitor(table, new OutputBuilder(outp)).visit(node);
}

final class GenVisitor : ResultVisitor!(OutputBuilder *) {
private:
    OutputBuilder *ob;
    SymbolTable table;

    alias ob this;

    void visitParameters(ProcDeclNode node)
    {
        foreach(i, x; node.parameters){
            this.ob.untabbed({
                this.ob.printf("%s %s", x.type.toCtype, x.name);
                if(i < node.parameters.length - 1){
                    this.ob.printf(", ");
                }
            });
        }
    }
public:
    this(SymbolTable table, ref OutputBuilder output)
    {
        this(table, &output);
    }

    this(SymbolTable table, OutputBuilder *output)
    {
        super(output);
        this.table = table;
        this.ob = output;
    }
override:
    OutputBuilder *visit(ASTNode node)
    {
        node.visit(this);
        return this.ob;
    }

    void visitProgramNode(ProgramNode node)
    {
        foreach(x; node.children){
            this.dispatch(x);
        }
    }

    void visitReturnNode(ReturnNode node)
    {
        printf("return");
        untabbed({
            if(node.value){
                this.printf(" ");
                dispatch(node.value);
            }
        });
    }

    void visitProcDecl(ProcDeclNode node)
    {
        printf(
            "%s %s(",
            node.returnType.toCtype,
            node.name
        );
        visitParameters(node);
        printfln(")");
        dispatch(node.bodyNode);
    }

    void visitCallNode(CallNode node)
    {
        dispatch(node.toCall);
        untabbed({
            this.printf("(");
            foreach(i, x; node.arguments){
                this.dispatch(x);
                if(i < node.arguments.length - 1){
                    this.printf(", ");
                }
            }
            this.printf(")");
        });
    }

    void visitBlockNode(BlockNode node)
    {
        block({
            foreach(x; node.children){
                dispatch(x);
                this.untabbed({
                    this.printfln(";");
                });
            }
        });
    }

    void visitIdentifierNode(IdentifierNode node)
    {
        printf(node.name);
    }

    void visitIntegerNode(IntegerNode node)
    {
        printf("%d", node.value);
    }

    void visitCharNode(CharNode node)
    {
        printf("%c", node.value);
    }
};
