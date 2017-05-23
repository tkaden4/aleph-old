module syntax.visitors.util;

import syntax.tree;

public class AnonymousVisitor(N, alias fun)
{
    public typeof(fun()) visit(N n)
    {
        return fun(n);
    }
};

public auto visitor(T: ProgramNode)()
{
    return programVisitor;
}
