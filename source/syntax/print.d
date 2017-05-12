module syntax.print;

import syntax.visit.Visitor;
import semantics.type;
import gen.OutputBuilder;
import util;

import std.string;
import std.range;
import std.algorithm;

public auto ref toPretty(T)(T node)
{
    auto x = new PrettifyVisitor;
    string res = "";
    x.dispatch(node, new OutputBuilder(new StringStream(res)));
    return res;
}

private class PrettifyVisitor : Visitor!(void, OutputBuilder*) {
private:
    bool newline;
protected:
    override void visit(ref CallNode node, OutputBuilder *res)
    {
        auto x = node.toCall;
        super.visit(x, res);
        node.toCall = x;
        res.untabbed({
            res.printf("(");
            node.arguments.headLast!(
                (x){
                    visit(x, res);
                    res.printf(", ");
                },
                (x){
                    visit(x, res);
                }
            );
            res.printf(")");
        });
    }

    override void visit(ref IfExpressionNode node, OutputBuilder *res)
    {
        with(res){
            printf("(if ");
            untabbed({
                this.visit(node.ifexp, res);
                printf(" then ");
                this.visit(node.thenexp, res);
                if(node.elseexp){
                        printf(" else ");
                        this.visit(node.elseexp, res);
                }
            });
            printf(")::[%s]", node.resultType.toPrintable);
        }
    }

    override void visit(ref BlockNode node, OutputBuilder *res)
    {
        this.newline = true;
        res.block({
            node.children.each!(x => visit(x, res));
        });
        this.newline = false;
    }

    override void visit(ref ReturnNode node, OutputBuilder *res)
    {
        res.printf("return ");
        res.untabbed({
            auto x = node.value;
            this.visit(x, res);
        });
    }

    override void visit(ref ProcDeclNode node, OutputBuilder *res)
    {
        with(res){
            untabbed({
                printf("proc %s(", node.name);
                node.parameters.headLast!(
                    x => printf("%s: %s, ", x.name, x.type.toPrintable),
                    x => printf("%s: %s", x.name, x.type.toPrintable)
                );
                printf(") -> %s = ", node.returnType.toPrintable);
            });
            visit(node.bodyNode, res);
            printfln("");
        }
    }

    override void visit(ref StatementNode node, OutputBuilder *res)
    {
        super.visit(node, res);
    }

    override void visit(ref ExpressionNode node, OutputBuilder *res)
    {
        super.visit(node, res);
        if(this.newline && res.usetabs){
            res.untabbed({
                res.printfln(";");
            });
        }
    }

    override void visit(ref IntegerNode node, OutputBuilder *res)
    {
        res.printf("%d", node.value);
    }

    override void visit(ref StringNode node, OutputBuilder *res)
    {
        res.printf("%s", node.value);
    }

    override void visit(ref IdentifierNode node, OutputBuilder *res)
    {
        res.printf("%s::[%s]", node.name, node.resultType.toPrintable);
    }

    override void visit(ref VarDeclNode node, OutputBuilder *res)
    {
        with(res){
            res.printf("let %s: %s = ", node.name, node.type.toPrintable);
            untabbed({
                visit(node.initVal, res);
            });
        }
    }
};
