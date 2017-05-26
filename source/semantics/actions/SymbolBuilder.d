module semantics.actions.SymbolBuilder;

import syntax.visitors;
import semantics;
import util;

import std.stdio;
import std.string;
import std.typecons;
import std.range;
import std.algorithm;


template SymbolBuilderProvider(alias Provider, Args...){
    VarDeclNode visit(VarDeclNode node, AlephTable table)
    {
        table.find(node.name, false).not.err(new AlephException("redefined variable %s".format(node.name)));
        table.insert(node.name, new VarSymbol(node.name, node.type, table));
        node.initVal.visit(table);
        return node;
    }

    ProcDeclNode visit(ProcDeclNode node, AlephTable table)
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
            node.bodyNode.visit(table);
            return node;
        });
    }

    ExternProcNode visit(ExternProcNode node, AlephTable table)
    {
        table.find(node.name).not.err(new AlephException("symbol %s defined".format(node.name)));
        table.insert(node.name, new FunctionSymbol(node.name, node.functionType, table, true));
        return node;
    }

    LambdaNode visit(LambdaNode node, AlephTable table)
    {
        return node;
    }

    T visit(T)(T t, Args args)
    {
        return DefaultProvider!(Provider, Args).visit(t, args);
    }
}

public auto buildSymbols(Tuple!(ProgramNode, AlephTable) tup)
{
    return alephErrorScope("symbol builder", {
        auto node = SymbolBuilderProvider!(SymbolBuilderProvider, AlephTable).visit(tup[0], tup[1]);
        return tuple(node, tup[1]);
    });
}
