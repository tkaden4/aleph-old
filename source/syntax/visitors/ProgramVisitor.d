module syntax.visitors.ProgramVisitor;

import syntax.tree.ProgramNode;
import syntax.visitors.DeclarationVisitor;

public class ProgramVisitor(alias getDeclVis) {
public:
    alias NodeType = ProgramNode;

    ProgramNode visit(ProgramNode node)
    {
        auto visitor = getDeclVis();
        foreach(ref x; node.children){
            x = visitor.visit(x);
        }
        return node;
    }
};

public auto programVisitor(alias getDecl=declarationVisitor)()
{
    return new ProgramVisitor!getDecl();
}
