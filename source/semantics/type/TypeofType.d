module semantics.type.TypeofType;

import semantics.type.Type;
import syntax.tree.ExpressionNode;

public class TypeofType : Type {
    this(ExpressionNode node)
    in{
        assert(node);
    }body{
        this.node = node;
    }

    override bool canCast(Type type)
    in {
        assert(type);
    } body {
        return type.canCast(this.node.resultType);
    }

    override string toString()
    {
        import std.string;
        return "TypeofType(%s)".format(this.node.resultType);
    }

    ExpressionNode node;
};
