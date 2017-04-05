module parse.visitors.ResultVisitor;

public import parse.visitors.ASTVisitor;

class ResultVisitor(T) : ASTVisitor {
    this(T t)
    {
        this.res = t;
    }

    T visit(ASTNode node)
    {
        node.visit(this);
        return this.result;
    }

    final @property T result()
    {
        return this.res;
    }

    final @property void result(T new_res)
    {
        this.res = new_res;
    }
private:
    T res;
};
