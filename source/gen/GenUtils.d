module gen.GenUtils;

import syntax.tree.ExpressionNode;

bool hasResult(ExpressionNode node)
{
    return node.resultType == Primitives.Void ? false : true;
}

string toCtype(Type type)
{
    return "int";
}
