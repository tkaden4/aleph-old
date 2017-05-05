module semantics.Desugar;

import std.stdio;
import std.range;
import std.algorithm : each;

import syntax.tree.visitors.ASTVisitor;
import semantics.symbol.Symbol;

import util;

public auto desugar(Tuple)(Tuple node)
{
    return tuple(node[0], node[1].desugar);
}

public ProgramNode desugar(ProgramNode node)
{
    return new Desugar(node).apply(node);
}

/* A few things the Desugarer does: 
 * - Adds ReturnNode to functions without them (implied returns)
 * - transforms IfExpressions into IfStatements that 
 *   assign to a temporary */


/* TODO make pure functions */
private class Desugar : ASTVisitor {
public:
    ProgramNode result;
    this(ProgramNode node){ this.result = node; }
    auto apply(ASTNode node)
    {
        try {
            this.dispatch(node);
            return this.result;
        }catch(Exception e){
            import std.string;
            throw new Exception("desugarer error: %s".format(e.msg));
        }
    }
override:
    void visit(ProgramNode node)
    {
        node.children.each!(x => this.dispatch(x));
    }

    void visit(ReturnNode node)
    {
        this.dispatch(node.value);
    }

    void visit(ProcDeclNode node)
    {
        // Add a return node
        node.bodyNode = node.addReturn.use!(
            x => node.bodyNode.match(
                     (BlockNode block) => block,
                     (ExpressionNode sub) => new BlockNode([sub])
                 )
        ).then!(x => this.dispatch(x));
    }

    // Unused functions
    void visit(ExternImportNode node){}
    void visit(ExternProcNode node){}
    void visit(IntegerNode node){}
    void visit(IdentifierNode node){}
    void visit(BlockNode node){}
}

private auto addReturn(ProcDeclNode pnode)
{
    pnode.bodyNode = pnode.bodyNode.use!(
        x => x.match(
            (ReturnNode n) => n,
            (BlockNode n) =>
                n.children.use!(x =>
                    x.back.match(
                        // No need to return a return node
                        (ReturnNode sub) => sub,
                        // Return the last expression
                        (ExpressionNode sub) => new ReturnNode(sub)
                    )
                    // If there is no back
                    .or(new ReturnNode(null))
                    .use!(
                        // append the new node to then end of the body
                        end => n.children[0..$-1] ~ end
                    )
                ).use!(x => cast(ExpressionNode)new BlockNode(x)),
            (ExpressionNode node) => cast(ExpressionNode)new ReturnNode(node)
        )
    );
    return pnode;
}
