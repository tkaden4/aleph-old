module semantics.Sugar;

import std.stdio;

import symbol.SymbolTable;
import symbol.Type;
import syntax.tree.visitors.ResultVisitor;
import std.range;

import util.match;

ASTNode desugar(ASTNode node)
{
    return new Sugar(node).visit(node);
}

/* A few things the Desugarer does: 
 * - Adds ReturnNode to functions without them (implied returns)
 * - transforms IfExpressions into IfStatements that 
 *   assign to a temporary */


class Sugar : ResultVisitor!ASTNode {
    this(ASTNode node){ super(node); }
override:
    void visitProgramNode(ProgramNode node)
    {
        foreach(x; node.children){
            x.visit(this);
        }
    }

    void visitReturnNode(ReturnNode node)
    {
        this.dispatch(node.value);
    }

    void visitProcDecl(ProcDeclNode node)
    {
        // Add a return node
        node.addReturn.bodyNode.match(
            (BlockNode k){},
            (ExpressionNode k){ node.bodyNode = new BlockNode([node.bodyNode]); }
        );
        this.dispatch(node.bodyNode);
    }

    // Unused functions
    void visitIntegerNode(IntegerNode node){}
    void visitIdentifierNode(IdentifierNode node){}
    void visitBlockNode(BlockNode node){}
}

auto addReturn(ProcDeclNode pnode)
{
    auto node = pnode.bodyNode;
    node.match(
        (BlockNode n){
            auto children = n.children;
            if(children.empty){
                pnode.bodyNode = new ReturnNode(null);
            }else{
                auto exp = children.back;
                exp.match(
                    (ReturnNode sub){},
                    (ExpressionNode sub){
                        n.children = n.children[0..$-1] ~ new ReturnNode(exp);
                    }
                );
                pnode.bodyNode = n;
            }
        },
        (ExpressionNode node){
            pnode.bodyNode = new ReturnNode(node);
        }
    );
    return pnode;
}
