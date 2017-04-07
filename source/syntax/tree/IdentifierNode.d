module syntax.tree.IdentifierNode;

public import syntax.tree.ExpressionNode;

/* TODO add ID type + deferred types */
class IdentifierNode : ExpressionNode {
public:
    this(string id, Type typ)
    {
        this.id = id;
        this.type = typ;
    }
    
    @property override Type resultType()
    {
        return this.type;
    }

    @property void resultType(Type t)
    {
        this.type = t;
    }

    @property string name() const
    {
        return this.id;
    }

    override string toString() const
    {
        import std.string;
        return "IdentifierNode(%s)".format(this.id);
    }
public:
    const string id;
    Type type;
};
