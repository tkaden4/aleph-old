module util.Errors;

import syntax.tree;
import semantics.symbol.AlephTable;
import std.typecons;

struct ErrorData {
    string[] files;
};

public struct CompilerData {
    ProgramNode node;
    AlephTable table;
    ErrorData data;
};

public abstract class CompilerAction {
    void enter(ref CompilerData data);
    CompilerData *leave();

    final auto chain(ref CompilerAction next)
    {
        next.enter(*this.leave);
    }
};
