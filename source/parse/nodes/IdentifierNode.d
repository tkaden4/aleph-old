module parse.nodes.IdentifierNode;

public import parse.nodes.ExpressionNode;

/* TODO add ID type + deferred types */
class IdentifierNode : ExpressionNode {
public:
    this(string id, Type type)
    {
        this.id = id;
        this.type = type;
    }
    
    override void visit(ASTVisitor tv){ tv.visitIdentifierNode(this); }

    override @property Type resultType()
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
private:
    const string id;
    Type type;
};