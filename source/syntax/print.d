module syntax.print;

import semantics.type;
import gen.OutputBuilder;
import util;

import std.string;
import std.range;
import std.algorithm;

public auto ref toPretty(T)(T node, bool types=false)
{
 //   auto x = new PrettifyVisitor(types);
    string res = "";
//    x.dispatch(node, new OutputBuilder(new StringStream(res)));
    return res;
}

/*

private class PrettifyVisitor : Visitor!(void, OutputBuilder*) {
private:
    bool statementexp;
    bool withTypes;
protected:
    this(bool withTypes = false)
    {
        this.withTypes = withTypes;
    }

    auto statem(T)(T body_fun)
    {
        auto k = this.statementexp;
        this.statementexp = true;
        body_fun();
        this.statementexp = k;
    }

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
            printf("if ");
            untabbed({
                this.visit(node.ifexp, res);
                printf(" then ");
            });
            block({
                this.statem({
                    this.visit(node.thenexp, res);
                });
            });
            if(node.elseexp){
                untabbed({
                    printf(" else ");
                    block({
                        this.statem({
                            this.visit(node.elseexp, res);
                        });
                    });
                    if(this.withTypes){
                        printf("::[%s]", node.resultType.toPrintable);
                    }
                });
            }
        }
    }

    override void visit(ref BlockNode node, OutputBuilder *res)
    {
        res.block({
            this.statem({
                node.children.each!(x => visit(x, res));
            });
        });
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
                printf("proc %s(", node.name);
            untabbed({
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
        if(this.statementexp && res.usetabs){
            res.untabbed({
                res.printfln(";");
            });
        }
    }

    override void visit(ref CharNode node, OutputBuilder *res)
    {
        res.printf("'%c'", node.value);
    }

    override void visit(ref BinOpNode node, OutputBuilder *res)
    {
        res.printf("(");
        res.untabbed({
            this.visit(node.left, res);
            res.printf(" %s ", node.op);
            this.visit(node.right, res);
            res.printf(")");
            if(this.withTypes){
                res.printf("::[%s]", node.resultType.toPrintable);
            }
        });
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
        res.printf("%s", node.name);
        if(this.withTypes){
            res.untabbed({
                res.printf("::[%s]", node.resultType.toPrintable);
            });
        }
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
*/
