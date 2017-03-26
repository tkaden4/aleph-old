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

    override string toString() const
    {
        import std.string;
        return "IdentifierNode(%s)".format(this.id);
    }
public:
    const string id;
    Type type;
};
