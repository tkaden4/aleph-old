module parse.nodes.ASTVisitor;

import std.string;

import parse.nodes.ASTException;
import parse.nodes.ASTNode;

template defaultASTVisit()
{
    override void visit(ASTVisitor visitor)
    {
        visitor.invoke(this);
    }
}

template visitorFunctions(bool decl=false, U: ASTNode, T...,)
{
    static if(decl){
        abstract void invoke(U node);
    }else{
        override void invoke(U node)
        {
            throw new ASTException("Unable to visit node:\n\t%s".format(node));
        }
    }

    static if(T.length){
        mixin visitorFunctions!(decl, T);
    }
}

class ASTVisitor {
    mixin visitorFunctions!(true, ASTNode);
};
