module syntax.tree.declaration.ExternImportNode;

import syntax.tree.expression.StatementNode;
import syntax.tree.declaration.DeclarationNode;

import std.string;

public class ExternImportNode : DeclarationNode {
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
