module gen.CGenerator;

import std.file;
import stdio = std.stdio;
import std.range;
import std.conv;
import std.range;
import std.algorithm;
import std.string;

import semantics;
import syntax;
import util;
import gen.TypeUtils;
public import gen.OutputBuilder;
import util.AlephException;

public auto cgenerate(Tuple)(Tuple t, OutputStream outp)
{
    return t.expand.cgenerate(outp);
}

public auto cgenerate(Program node, AlephTable table, OutputStream outp)
{
    return alephErrorScope("c generator", () =>
        new CGenerator(new OutputBuilder(outp), table).apply(node)
    );
}

private class CGenerator {
private:
    OutputBuilder *ob;
    alias ob this;
    AlephTable table;
public:
    this(OutputBuilder *builder, AlephTable table)
    {
        this.table = table;
        this.ob = builder;
    }

    invariant
    {
        assert(this.ob, "No output builder");
    }
    
    auto apply(Program node)
    {
        this.ob.printfln("/* Generated by the Aleph compiler v0.0.1 */");
        this.visit(node);
        return this.ob;
    }

    void visit(BinaryExpression node)
    {
        this.visit(node.left);
        this.untabbed({
            this.printf(" %s ", node.op);
            this.visit(node.right);
        });
    }

    void visit(Program node)
    {
        foreach(x; this.table.libraryPaths){
            this.printfln("#include\"%s\"", x);
        }
        this.printfln("");
        foreach(x; node.children){
            this.visit(x);
            this.untabbed({
                this.printfln(";");
            });
        }
    }

    void visit(Declaration node)
    {
        node.match(
            (ProcDecl func) => this.visit(func),
            (StructDecl s){
                this.printf("struct %s ", s.name);
                this.untabbed({
                    this.block({
                        foreach(x; s.fields){
                            this.printfln("%s;", x.type.typeString(x.name));
                        }
                    });
                });
            },
            (VarDecl n) => this.visit(n),
            (ExternProc node){
                this.untabbed({
                    this.printf("extern ");
                    string inside = node.name ~ "(";
                    node.parameterTypes.headLast!(x => inside ~= x.typeString ~ ", ",
                                                  x => inside ~= x.typeString);
                    if(node.isvararg){
                        inside ~= "%s...".format(node.parameterTypes.length == 0 ? "" : ", ");
                    }
                    inside ~= ")";
                    this.printf("%s", node.returnType.typeString(inside));
                });
            },
            (ExternImport pre){
                this.untabbed({
                    this.printfln("#include\"%s\"", pre.file);
                });
            }
        );
    }

    void visit(ProcDecl node)
    {
        this.untabbed({
            string inside = node.name ~ "(";
            node.parameters.headLast!(
                    i => inside ~= ("%s, ".format(i.type.typeString(i.name))),
                    k => inside ~= ("%s".format(k.type.typeString(k.name))));
            inside ~= ")";
            import std.stdio;
            this.printf("%s %s", "extern", node.returnType.typeString(inside));
        });
        this.visit(node.bodyNode);
    }

    void visit(Block node)
    {
        this.block({
            node.children.each!((x){
                this.visit(x);
                this.untabbed({
                    this.printfln(";");
                });
            });
        });
    }

    void visit(Statement node)
    {
        node.match(
            (Declaration n){
                this.visit(n);
            },
            (Return n){
                this.printf("return ");
                this.untabbed({
                    this.visit(n.value);
                });
            },
        );
    }

    void visit(VarDecl node)
    {
        import std.string;
        this.printf("%s %s", "auto", node.type.typeString(node.name));
        if(node.initVal){
            this.untabbed({
                this.printf(" = ");
                this.visit(node.initVal);
            });
        }
    }

    void visit(Expression node)
    {
        import std.stdio;
        node.match(
            (Statement n) =>
                this.visit(n),
            (Cast n){
                this.untabbed({
                    this.printf("(%s)", n.castType.typeString);
                });
                this.visit(n.node);
            },
            (IfExpression n){
            },
            (IntPrimitive n) =>
                this.printf("%d", n.value),
            (StringPrimitive n) =>
                this.printf("\"%s\"", n.value),
            (CharPrimitive n) =>
                this.printf("\'%c\'", n.value),
            (Block n) =>
                this.visit(n),
            (BinaryExpression n) =>
                this.visit(n),
            (Identifier n){
                this.printf("%s", n.name);
            },
            (Call n){
                this.visit(n.toCall);
                this.untabbed({
                    this.printf("(");
                    n.arguments.headLast!((x){ this.visit(x); this.printf(", "); },
                                          (k){ this.visit(k); });
                    this.printf(")");
                });
            }
        );
    }
};
