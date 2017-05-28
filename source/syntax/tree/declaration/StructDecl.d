module syntax.tree.declaration.StructDecl;

import syntax.tree.declaration.Declaration;
import semantics.type.Type;

public class StructDecl : Declaration {
    import std.string;
    public struct Field {
        string name;
        Type type;

        string toString() const
        {
            return "Field(%s, %s)".format(this.name, this.type.toPrintable);
        }
    };
public:
    this(in string name, Field[] fields)
    {
        this.fields = fields;
        this.name = name;
    }

    override string toString() const
    {
        return "StructDecl(%s, %s)".format(this.name, this.fields);
    }

    string name;
    Field[] fields;
};
