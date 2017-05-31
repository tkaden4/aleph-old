module syntax.print;

import syntax.visitors;
import semantics.type;
import gen.OutputBuilder;
import util;

import std.string;
import std.range;
import std.algorithm;

struct PrettifyContext {
    bool statementexp;
    bool withTypes;
    OutputBuilder *builder;
};

public auto ref toPretty(T)(T node, bool types=false)
{
    string res = "";
    auto output = new OutputBuilder(new StringStream(res));
    PrettifyProvider!(PrettifyProvider, PrettifyContext *)
        .visit(node, new PrettifyContext(false, types, output));
    return res;
}
auto statem(alias body_fun)(PrettifyContext *ctx)
{
    auto k = ctx.statementexp;
    ctx.statementexp = true;
    body_fun();
    ctx.statementexp = k;
}

template PrettifyProvider(alias Provider, Args...) {
    alias defVis = DefaultProvider!(Provider, Args);

    Call visit(Call node, PrettifyContext *ctx)
    {
        defVis.visit(node.toCall, ctx);
        with(ctx.builder){
            untabbed({
                printf("(");
                node.arguments.headLast!(
                    (x){
                        x.visit(ctx);
                        printf(", ");
                    },
                    (x){
                        x.visit(ctx);
                    }
                );
                printf(")");
            });
        }
        return node;
    }

    IfExpression visit(IfExpression node, PrettifyContext *ctx)
    {
        with(ctx.builder){
            printf("if ");
            untabbed({
                node.ifexp.visit(ctx);
                printf(" then ");
            });
            block({
                ctx.statem!({
                    node.thenexp.visit(ctx);
                });
            });
            if(node.elseexp){
                untabbed({
                    printf(" else ");
                    block({
                        ctx.statem!({
                            node.elseexp.visit(ctx);
                        });
                    });
                    if(ctx.withTypes){
                        printf("::[%s]", node.resultType.toPrintable);
                    }
                });
            }
        }
        return node;
    }

    Block visit(Block node, PrettifyContext *ctx)
    {
        with(ctx.builder){
            block({
                ctx.statem!({
                    node.children.each!(x => visit(x, ctx));
                });
            });
        }
        return node;
    }

    auto visit(Return node, PrettifyContext *ctx)
    {
        with(ctx.builder){
            printf("return ");
            untabbed({
                node.value = node.value.visit(ctx);
            });
        }
        return node;
    }

    auto visit(ProcDecl node, PrettifyContext *ctx)
    {
        with(ctx.builder){
            printf("proc %s(", node.name);
            untabbed({
                node.parameters.headLast!(
                    x => printf("%s: %s, ", x.name, x.type.toPrintable),
                    x => printf("%s: %s", x.name, x.type.toPrintable)
                );
                printf(") -> %s = ", node.returnType.toPrintable);
            });
            node.bodyNode.visit(ctx);
            printfln("");
        }
        return node;
    }

    Expression visit(Expression node, PrettifyContext *ctx)
    {
        with(ctx.builder){
            defVis.visit(node, ctx);
            if(ctx.statementexp && ctx.builder.usetabs){
                untabbed({
                    printfln(";");
                });
            }
        }
        return node;
    }

    auto visit(Cast c, PrettifyContext *ctx)
    {
        with(ctx.builder){
            untabbed({
                c.node = c.node.visit(ctx);
                printfln(" : %s", c.castType.toPrintable);
            });
        }
        return c;
    }

    auto visit(BinaryExpression node, PrettifyContext *ctx)
    {
        with(ctx.builder){
            printf("(");
            untabbed({
                node.left.visit(ctx);
                printf(" %s ", node.op);
                node.right.visit(ctx);
                printf(")");
                if(ctx.withTypes){
                    printf("::[%s]", node.resultType.toPrintable);
                }
            });
        }
        return node;
    }

    auto visit(CharPrimitive node, PrettifyContext *res) {
       res.builder.printf("%c", node.value);
       return node;
    }

    auto visit(IntPrimitive node, PrettifyContext *res) {
       res.builder.printf("%d", node.value);
       return node;
    }

    auto visit(StringPrimitive node, PrettifyContext *res) {
       res.builder.printf("%s", node.value);
       return node;
    }

    auto visit(Identifier node, PrettifyContext *ctx)
    {
        with(ctx.builder){
            printf("%s", node.name);
            if(ctx.withTypes){
                untabbed({
                    printf("::[%s]", node.resultType.toPrintable);
                });
            }
        }
        return node;
    }

    auto visit(VarDecl node, PrettifyContext *ctx)
    {
        import std.stdio;
        with(ctx.builder){
            printf("let %s: %s = ", node.name, node.type.toPrintable);
            untabbed({
                node.initVal.visit(ctx);
            });
        }
        return node;
    }

    Statement visit(Statement n, Args args)
    {
        return defVis.visit(n, args);
    }

    Declaration visit(Declaration n, Args args)
    {
        return defVis.visit(n, args);
    }
};
