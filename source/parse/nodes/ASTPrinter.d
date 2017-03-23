module parse.nodes.ASTPrinter;

import parse.nodes.ASTVisitor;

class ASTPrinter : ASTVisitor {
    mixin visitorFunctionImpl!(false, ASTNode);
};
