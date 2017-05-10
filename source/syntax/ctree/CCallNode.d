module syntax.ctree.CCallNode;

import syntax.ctree.CExpressionNode;
import semantics.ctype;

import util;

public class CCallNode : CExpressionNode {
    this(CExpressionNode toCall, CExpressionNode[] arguments)
    {
        this.toCall = toCall;
        this.arguments = arguments;
    }

    @property CType type()
    {
        return this.toCall.type.use!(
            x => x.match(
                (CFunctionType t) => t.returnType,
                (CType t) => null
            )
        );
    }

    CExpressionNode toCall;
    CExpressionNode[] arguments;
};
