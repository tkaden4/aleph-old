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

    @property void result(T new_res)
    {
        this.res = new_res;
    }
private:
    T res;
};
