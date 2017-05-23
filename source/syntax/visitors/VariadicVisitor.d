module syntax.visitors.VariadicVisitor;

public class VariadicVisitor(T, N) : T {
private:
    T[] vs;
public:
    this(T[] visitors)
    {
        this.vs = visitors;
    }

    public override N visit(N n)
    {
        foreach(x; this.vs){
            n = x.visit(n);
        }
        return n;
    }
};

public auto variadicVisitor(F, T...)(F f, T ts)
{
    return new VariadicVisitor!(F, F.NodeType)([f, ts]);
}
