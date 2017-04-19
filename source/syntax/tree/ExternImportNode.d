module syntax.tree.ExternImportNode;

import syntax.tree.StatementNode;

import std.string;

public class ExternImportNode : StatementNode {
    this(string file)
    {
        this.file = file;
    }

    string file;

    override string toString()
    {
        return "Import(%s)".format(this.file);
    }
};
