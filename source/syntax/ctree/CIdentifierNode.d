module syntax.ctree.CIdentifierNode;

import syntax.ctree.CExpressionNode;

public class CIdentifierNode : CExpressionNode {
    this(string value, CType _type)
    {
        this.name = value;
        this._type = _type;
    }

    @property CType type()
    {
        return this._type;
    }

    string name;
    CType _type;
};
