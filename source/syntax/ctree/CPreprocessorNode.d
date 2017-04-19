module syntax.ctree.CPreprocessorNode;

import syntax.ctree.CTopLevelNode;

public class CPreprocessorNode : CTopLevelNode {
    this(string value)
    {
        this.value = value;
    }

    string value;
};
