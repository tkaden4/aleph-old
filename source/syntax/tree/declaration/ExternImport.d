module syntax.tree.declaration.ExternImport;

import syntax.tree.expression.Statement;
import syntax.tree.declaration.Declaration;

import std.string;

public class ExternImport : Declaration {
    this(in string file)
    {
        this.file = file;
    }

    string file;

    override string toString() const
    {
        return "ExternImport(%s)".format(this.file);
    }
};
