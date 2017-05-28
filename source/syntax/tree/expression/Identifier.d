module syntax.tree.expression.Identifier;

public import syntax.tree.expression.Expression;

/* TODO add ID type + deferred types */
public class Identifier : Expression {
public:
    this(in string id, Type typ)
    {
        super(typ);
        this.id = id;
    }
    
    @property ref const(string) name() const
    {
        return this.id;
    }

    override string toString() const
    {
        import std.string;
        return "Identifier(%s)".format(this.id);
    }
public:
    const string id;
};
