module syntax.visit.Visitor;

public import syntax.tree;
import util;
import syntax.print;

import std.range;
import std.algorithm;
import std.stdio;
import std.string;


/* TODO moving to new visitor */

public auto ref dispatch(N, R, Args...)(Visitor!(R, Args) vis, N node, Args args)
{
    vis.visit(node, args);
    return vis;
}

public class Visitor(R, Args...) {
public:
    R visit(ref ProgramNode node, Args args)
    {
        node.children.each!(x => this.visit(x, args));
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref ProcDeclNode node, Args args)
    {
        this.visit(node.bodyNode, args);
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref BinOpNode node, Args args)
    {
        this.visit(node.left, args);
        this.visit(node.right, args);
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref BlockNode node, Args args)
    {
        foreach(x; node.children){
            this.visit(x, args);
        }
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref IfExpressionNode node, Args args)
    {
        this.visit(node.ifexp, args);
        this.visit(node.thenexp, args);
        node.elseexp.then!(x => this.visit(x, args));
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref DeclarationNode node, Args args)
    {
        node.match(
            (VarDeclNode n)  => this.visit(n, args),
            (ProcDeclNode n) => this.visit(n, args),
            (ExternProcNode n) => this.visit(n, args),
            (ExternImportNode n) => this.visit(n, args),
            (){ throw new AlephException("couldn't visit %s".format(node)); }
        );
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref ExternImportNode node, Args args)
    {
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref ExpressionNode node, Args args)
    {
        import std.string;
        node.match(
            (StatementNode node)    => this.visit(node, args),
            (IfExpressionNode node) => this.visit(node, args),
            (IntegerNode node)      => this.visit(node, args),
            (CallNode node)         => this.visit(node, args),
            (BlockNode node)        => this.visit(node, args),
            (IdentifierNode node)   => this.visit(node, args),
            (StringNode node)       => this.visit(node, args),
            (IntegerNode node)      => this.visit(node, args),
            (CharNode node)         => this.visit(node, args),
            (BinOpNode node)        => this.visit(node, args),
            (LambdaNode node)       => this.visit(node, args),
            (CastNode node)         => this.visit(node, args),
            (ExpressionNode node){ throw new AlephException("couldn't visit %s".format(node)); },
        );
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref LambdaNode node, Args args)
    {
        this.visit(node.bodyNode, args);
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref CastNode node, Args args)
    {
        static if(!is(R == void)){
            return this.visit(node.node, args);
        }else{
            this.visit(node.node, args);
        }
    }

    R visit(ref IntegerNode node, Args args)
    {
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref CharNode node, Args args)
    {
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref StringNode node, Args args)
    {
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref StatementNode node, Args args)
    {
        node.match(
            (DeclarationNode node) => this.visit(node, args),
            (ReturnNode n)         => this.visit(n, args),
            (){ throw new AlephException("couldn't visit %s".format(node)); }
        );
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref ReturnNode node, Args args)
    {
        auto x = node.value;
        this.visit(x, args);
        node = new ReturnNode(x);
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref ExternProcNode node, Args args)
    {
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref IdentifierNode node, Args args)
    {
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref VarDeclNode node, Args args)
    {
        this.visit(node.initVal, args);
        static if(!is(R == void)){
            return R.init;
        }
    }

    R visit(ref CallNode node, Args args)
    {
        auto c = node.toCall;
        this.visit(c, args);
        node.toCall = c;
        static if(!is(R == void)){
            return R.init;
        }
    }
};
