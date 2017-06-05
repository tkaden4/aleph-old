module syntax.tree.expression.Expression;

public import semantics.type;

public abstract class Expression {
public:
    this(Type type)
    {
        this.resultType = type;
    }

    abstract override string toString() const;

    Type resultType;
};
