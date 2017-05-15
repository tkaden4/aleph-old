module syntax.tree.declaration.ExternImportNode;

import syntax.tree.expression.StatementNode;

import std.string;

public class ExternImportNode : StatementNode {
    this(in string file)
    {
        this.file = file;
    }

    string file;

    override string toString()
    {
        return "Import(%s)".format(this.file);
    }
};
