module semantics.actions.SymbolBuilder;

import std.typecons;
import std.string;
import std.algorithm;
import std.range;

import semantics.symbol;
import semantics.type;
import syntax.visit.Visitor;
import util;
import AlephException;


public auto buildSymbols(Tuple!(ProgramNode, AlephTable) t)
{
    return alephErrorScope("symbol builder", {
        new SymbolBuilder().dispatch(t[0], t[1]);
        return t;
    });
}

private class SymbolBuilder : Visitor!(void, AlephTable) {
    override void visit(ref ProcDeclNode node, AlephTable table)
    {
        alephErrorScope("in function " ~ node.name, {
            auto name = node.name;
            table.find(name).not.err(new AlephException("symbol %s already defined".format(name)));
            /* create the function's symbol table */
            auto funTable = new AlephTable("%s's table".format(name), table);
            /* get the symbol parameters and add them to function */
            auto paramSyms = node.parameters.map!(x => new VarSymbol(x.name, x.type, funTable)).array;
            paramSyms.each!(x => funTable.insert(x.name, x));
            /* create the function symbol */
            auto funSymbol = new FunctionSymbol(name, node.functionType, funTable, false);
            /* add the funciton to the symbol table */
            table.insert(name, funSymbol);
            super.visit(node, table);
        });
    }

    override void visit(ref VarDeclNode node, AlephTable table)
    {
        table.find(node.name, false).not.err(new AlephException("redefined variable %s".format(node.name)));
        table.insert(node.name, new VarSymbol(node.name, node.type, table));
        super.visit(node, table);
    }

    override void visit(ref ExternProcNode node, AlephTable table)
    {
        table.find(node.name).not.err(new AlephException("symbol %s defined".format(node.name)));
        table.insert(node.name, new FunctionSymbol(node.name, node.functionType, table, true));

    }
};
