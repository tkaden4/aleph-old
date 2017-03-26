module parse.visitors.ResultVisitor;

public import parse.visitors.ASTVisitor;

class ResultVisitor(T) : ASTVisitor {
    @property T result()
    {
        return this.res;
    }
protected:
    T res;
};
