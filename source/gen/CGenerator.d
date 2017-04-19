module gen.CGenerator;

import std.file;
import stdio = std.stdio;
import std.range;
import std.conv;

import util;
import syntax.ctree;
import syntax.transform;

import semantics.SymbolTable;
import semantics.symbol.Symbol;

public import gen.OutputBuilder;

import std.range;
import std.algorithm;
import std.string;

public auto cgenerate(Tuple)(Tuple t, OutputStream outp)
{
    return t.expand.cgenerate(outp);
}

public auto cgenerate(CProgramNode node, SymbolTable!CSymbol table, OutputStream outp)
{
    try{
        return new CGenerator(table, new OutputBuilder(outp)).apply(node);
    }catch(Exception e){
        throw new Exception("generation error: %s".format(e.msg));
    }
}

private class CGenerator {
private:
    OutputBuilder *ob;
    alias ob this;
    SymbolTable!CSymbol symtab;
public:
    this(SymbolTable!CSymbol table, OutputBuilder *builder)
    {
        this.symtab = table;
        this.ob = builder;
    }

    invariant
    {
        assert(this.ob, "No output builder");
        assert(this.symtab, "No symbol table");
    }
    
    auto apply(CProgramNode node)
    {
        this.ob.printfln("/* Generated by the Aleph compiler v0.0.1 */");
        this.visit(node);
        return this.ob;
    }

    void visit(CProgramNode node)
    {
        foreach(x; node.children){
            this.visit(x);
        }
    }

    void visit(CTopLevelNode node)
    {
        node.match(
            (CFuncDeclNode func) => this.visit(func)
        );
    }

    void visit(CFuncDeclNode node)
    {
        this.untabbed({
            this.printf("%s %s %s(", node.storageClass.toString,
                                     node.returnType.typeString,
                                     node.name);
            node.parameters.headLast!(
                    i => this.printf("%s %s, ", i.type.typeString, i.name),
                    k => this.printf("%s %s", k.type.typeString, k.name));
            this.printfln(")");
        });
        this.visit(node.bodyNode);
    }

    void visit(CBlockStatementNode node)
    {
        this.block({
            node.children.each!(x => this.visit(x));
        });
    }

    void visit(CStatementNode node)
    {
        node.match(
            (CExpressionNode n) => this.visit(n),
            (CReturnNode n){
                this.statement({
                    this.printf("return ");
                    this.untabbed({
                        this.visit(n.exp);
                    });
                });
            },
            (CBlockStatementNode n) => this.visit(n),
            (CTypedefNode n) => this.visit(n),
            (CVarDeclNode n) => this.visit(n),
            (CStatementNode n){ this.printfln(";"); }
        );
    }

    void visit(CVarDeclNode node)
    {
        import std.string;
        this.statement({
            this.printf("%s %s %s", node.storageClass.toString, node.type.typeString, node.name);
            if(node.initVal){
                this.untabbed({
                    this.printf(" = ");
                    this.visit(node.initVal);
                });
            }
        });
    }

    void visit(CExpressionNode node)
    {
        import std.stdio;
        node.match(
            (CLiteralNode x){
                this.printf(x.match(
                                   (StringLiteral x) => x.value,
                                   (IntLiteral x) => x.value.to!string)
                );
            },
            (CIdentifierNode n){
                this.printf("%s", n.name);
            }
        );
    }

    void visit(CTypedefNode node)
    {
        this.printfln("typedef %s %s;", node.ctype.typeString, node.totype);
    }
};

private string typeString(CType t)
{
    import util;
    return t.use_err!(t => t.match((CPrimitive t) => t.name,
                            (CType t) => "unknown"))(new Exception("Null type"));
}

