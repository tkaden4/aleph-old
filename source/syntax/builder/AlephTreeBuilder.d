module syntax.builder.AlephTreeBuilder;

import syntax.tree;
import semantics;
import util;

public class AlephNodeFactory {
private:
    ProcDeclNode[] functions;
    AlephTable table;
public:
    this(AlephTable table)
    in {
        assert(table);
    } body {
        this.table = table;
    }

    ProcDeclNode procedure(string name, Type returnType)
    {
        return new ProcDeclNode(name, returnType, null, null);
    }

    auto variable()
    {
    }

    auto returnFrom()
    {
        /*
        this.currentFunction.err(new AlephException("Not currently in a function"));
        return
        */
    }
};
