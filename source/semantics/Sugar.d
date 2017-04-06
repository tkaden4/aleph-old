module semantics.Sugar;

import std.stdio;

import symbol.SymbolTable;
import symbol.Type;
import syntax.tree.visitors.ResultVisitor;

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
        addReturn(node);
        if(auto c = cast(BlockNode)node.bodyNode){
        }else{
            node.bodyNode = new BlockNode([node.bodyNode]);
        }
        this.dispatch(node.bodyNode);
    }

    void visitIntegerNode(IntegerNode node)
    {
    }

    void visitIdentifierNode(IdentifierNode node)
    {
    }

    void visitBlockNode(BlockNode node)
    {
    }
}

import std.range;
void addReturn(ProcDeclNode pnode)
{
    auto node = pnode.bodyNode;
    if(auto c = cast(BlockNode)node){
        auto children = c.children;
        if(!children || children.empty){
            pnode.bodyNode = new ReturnNode(null);
        }else{
            auto exp = children.back;
            c.children = c.children[0..$-1] ~ new ReturnNode(exp);
            pnode.bodyNode = c;
        }
    }else if(auto c = cast(IdentifierNode)node){
        pnode.bodyNode = new ReturnNode(c);
    }else if(auto c = cast(IntegerNode)node){
        pnode.bodyNode = new ReturnNode(c);
    }else{
        throw new Exception("Unable to return");
    }
}
