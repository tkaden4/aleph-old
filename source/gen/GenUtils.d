module gen.GenUtils;

import parse.nodes.ExpressionNode;
import parse.nodes.ASTNode;

bool hasResult(ExpressionNode node)
{
    return node.resultType == Primitives.Void ? false : true;
}

string toCtype(Type type)
{
    return "int";
}
