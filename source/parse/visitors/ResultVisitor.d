module parse.visitors.ResultVisitor;

public import parse.visitors.ASTVisitor;

class ResultVisitor(T) : ASTVisitor {
    this(T t)
    {
        this.res = t;
    }

    @property T result()
    {
        return this.res;
    }
protected:
    T res;
};
