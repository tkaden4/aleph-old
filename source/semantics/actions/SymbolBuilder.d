module semantics.actions.SymbolBuilder;

import syntax.visit;
import semantics;
import util;

import std.stdio;
import std.string;
import std.typecons;
import std.range;
import std.algorithm;

public auto buildSymbols(Tuple!(Program, AlephTable) tup)
{
    return alephErrorScope("symbol builder", {
        auto node = tup[0].visit(SymbolBuilder(tup[1]));
        return tuple(node, tup[1]);
    });
}

struct SymbolBuilder {
    private AlephTable table;

    @disable this();

    this(AlephTable table)
    {
        this.table = table;
    }

    auto visit(Program prog)
    {
        return prog;
    }

    auto visit(Expression exp)
    {
        return exp;
    }

    VarDecl visit(VarDecl node)
    {
        table.find(node.name, false).not.err(new AlephException("redefined variable %s".format(node.name)));
        table.insert(node.name, new VarSymbol(node.name, node.type, table));
        node.initVal.visit(this);
        return node;
    }

    ProcDecl visit(ProcDecl node)
    {
        return alephErrorScope("in function " ~ node.name, {
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
            node.bodyNode.visit(this);
            return node;
        });
    }

    auto visit(ExternProc node)
    {
        table.find(node.name).not.err(new AlephException("symbol %s defined".format(node.name)));
        table.insert(node.name, new FunctionSymbol(node.name, node.functionType, table, true));
        return node;
    }

    auto visit(Lambda node)
    {
        return node;
    }
}
