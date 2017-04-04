module gen.Generator; 

import symbol.SymbolTable;
import parse.visitors.ASTVisitor;
import parse.visitors.ASTPrinter;
import gen.GenUtils;

import std.file;
import std.stdio;

import std.container;

final class Generator {
public:
    this(SymbolTable table, ref File output)
    {
        this(table, &output);
    }

    this(SymbolTable table, File *output)
    {
        assert(output);
        this.visitor = new GenVisitor(table, output);
    }

    void generate(ASTNode node)
    {
        node.visit(this.visitor);
    }
private:
    GenVisitor visitor;

    final class GenVisitor : ASTVisitor {
    private:
        import std.conv;

        File *output;
        SymbolTable table;
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
                    "%s %s()",
                    node.returnType.toCtype,
                    node.name
                );
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
};
