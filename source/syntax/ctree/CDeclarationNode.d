module syntax.ctree.CDeclarationNode;

protected import syntax.ctree.CStatementNode;
protected import syntax.ctree.CTopLevelNode;


enum CStorageClass {
    STATIC,
    EXTERN,
    AUTO
};

class CDeclarationNode : CStatementNode, CTopLevelNode {
    this(CStorageClass sclass)
    {
        this.storageClass = sclass;
    }
public:
    CStorageClass storageClass;
};
