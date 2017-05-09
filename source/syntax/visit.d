module syntax.visit.Visitor;

import syntax.tree;
import util;
import std.range;
import std.algorithm;
import std.stdio;
import std.parallelism;

public abstract class Visitor(R, Args...) {
public:
    public R visit(ref ProgramNode node, Args args)
    {
        node.children.each!(x => this.visit(x, args));
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref ProcDeclNode node, Args args)
    {
        this.visit(node.bodyNode, args);
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref BlockNode node, Args args)
    {
        node.children.each!(x => this.visit(x, args));
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref IfExpressionNode node, Args args)
    {
        this.visit(node.ifexp, args);
        this.visit(node.thenexp, args);
        node.elseexp.then!(x => this.visit(x, args));
        static if(typeid(R) != typeid(void)){
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
            (ExpressionNode node){ throw new Exception("couldn't visit %s".format(node)); },
        );
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref IntegerNode node, Args args)
    {
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref CharNode node, Args args)
    {
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref StringNode node, Args args)
    {
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref StatementNode node, Args args)
    {
        node.match(
            (ReturnNode n)   => this.visit(n, args),
            (VarDeclNode n)  => this.visit(n, args),
            (ProcDeclNode n) => this.visit(n, args),
            (ImportNode n)   => this.visit(n, args),
            (ExternProcNode n) => this.visit(n, args),
            (ExternImportNode n){},
        );
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref ImportNode node, Args args)
    {
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref ReturnNode node, Args args)
    {
        auto x = node.value;
        this.visit(x, args);
        node = new ReturnNode(x);
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref ExternProcNode node, Args args)
    {
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref IdentifierNode node, Args args)
    {
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref VarDeclNode node, Args args)
    {
        this.visit(node.initVal, args);
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }

    R visit(ref CallNode node, Args args)
    {
        auto c = node.toCall;
        this.visit(c, args);
        node.toCall = c;
        static if(typeid(R) != typeid(void)){
            return R.init;
        }
    }
};
