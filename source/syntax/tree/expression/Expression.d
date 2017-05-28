module syntax.tree.expression.Expression;

public import syntax.tree.ASTNode;
public import semantics.type;

public abstract class Expression : ASTNode {
public:
    this(Type type)
    {
        this.resultType = type;
    }

    abstract override string toString() const;

    Type resultType;
};
