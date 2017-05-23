module syntax.visitors.ProgramVisitor;

import syntax.tree.ProgramNode;
import syntax.visitors.DeclarationVisitor;

public class ProgramVisitor {
public:
    alias NodeType = ProgramNode;

    ProgramNode visit(ProgramNode node)
    {
        auto visitor = new DeclarationVisitor;
        foreach(ref x; node.children){
            x = visitor.visit(x);
        }
        return node;
    }
};

public auto programVisitor()
{
    return new ProgramVisitor;
}
