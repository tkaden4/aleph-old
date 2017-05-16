module syntax.tree.declaration.StructDeclNode;

import syntax.tree.declaration.DeclarationNode;
import semantics.type.Type;

public class StructDeclNode : DeclarationNode {
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
        return "StructDeclNode(%s, %s)".format(this.name, this.fields);
    }

    string name;
    Field[] fields;
};
