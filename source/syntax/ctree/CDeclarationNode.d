module syntax.ctree.CDeclarationNode;

protected import syntax.ctree.CStatementNode;
protected import syntax.ctree.CTopLevelNode;


enum CStorageClass {
    STATIC,
    EXTERN,
    AUTO
};

public string toString(CStorageClass s)
{
    final switch(s){
    case CStorageClass.STATIC: return "static";
    case CStorageClass.EXTERN: return "extern";
    case CStorageClass.AUTO:   return "auto";
    }
}

class CDeclarationNode : CStatementNode, CTopLevelNode {
    this(CStorageClass sclass)
    {
        this.storageClass = sclass;
    }
public:
    CStorageClass storageClass;
};
