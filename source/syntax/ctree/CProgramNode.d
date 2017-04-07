module syntax.ctree.CProgramNode;

import syntax.ctree.CTreeNode;
import syntax.ctree.CTopLevelNode;

class CProgramNode : CTreeNode {
public:
    this(CTopLevelNode[] nodes)
    {
        this.children = nodes;
    }

    invariant
    {
        foreach(x; this.children){
            assert(x, "Null top level node");
        }
    }

    CTopLevelNode[] children;
};
