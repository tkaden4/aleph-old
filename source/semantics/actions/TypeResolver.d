module semantics.actions.TypeResolver;

/* 
 * Performs all type inferencing
 */

import std.typecons;
import std.range;
import std.algorithm;
import std.stdio;
import std.string;

import syntax;
import semantics;
import util;

public auto resolveTypes(Tuple!(ProgramNode, AlephTable) t)
{
    return t.expand.resolveTypes;
}

public auto resolveTypes(ProgramNode node, AlephTable table)
in {
    assert(node);
    assert(table);
} out(t) {
    assert(t[0]);
    assert(t[1]);
} body {
    return alephErrorScope("type resolver", {
        node = TypeResolveProvider!(TypeResolveProvider, AlephTable).visit(node, table);
        return tuple(node, table);
    });
}


template TypeResolveProvider(alias Provider, Args...)
{
    Type evaluateType(N)(N def, Type t, AlephTable table)
    {
        return t.match(
            (UnknownType _){
                return def.resultType;
            },
            (TypeofType t){
                if(!t.isResolved){
                    t.node = t.node.visit(table);
                }
                return t.node.resultType;
            },
            emptyFunc!Type
        );
    }

    VarDeclNode visit(VarDeclNode node, AlephTable table)
    {
        node = DefaultProvider!(Provider, Args).visit(node, table);
        auto sym = table.find(node.name).err(new Exception("Symbol %s not defined".format(node.name)));
        auto type = evaluateType(node.initVal, node.type, table);
        sym.type = type;
        node.type = type;
        return node;
    }

    BlockNode visit(BlockNode node, AlephTable table)
    {
        node = DefaultProvider!(Provider, Args).visit(node, table);
        node.resultType = node.children.back.use!(x => x.resultType).or(PrimitiveType.Void);
        return node;
    }

    IfExpressionNode visit(IfExpressionNode node, AlephTable table)
    {
        node.ifexp = node.ifexp.visit(table);
        node.thenexp = node.thenexp.visit(table);
        if(node.elseexp){
            node.elseexp = node.elseexp.visit(table);
        }
        node.resultType = node.thenexp.resultType;
        return node;
    }

    ProcDeclNode visit(ProcDeclNode node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("Function %s not defined".format(node.name)));
        sym.match(
            (FunctionSymbol f){
                node.bodyNode = node.bodyNode.visit(f.bodyScope);
                auto type = evaluateType(node.bodyNode, node.returnType, table);
                node.returnType = type;
                sym.type = node.functionType;
            },
            (){ throw new AlephException("no function named %s".format(node.name)); }
        );
        return node;
    }

    BinOpNode visit(BinOpNode node, AlephTable table)
    {
        node.left = node.left.visit(table);
        node.right = node.right.visit(table);

        auto leftType = node.left.resultType;
        auto rightType = node.right.resultType;

        if(leftType.canCast(rightType)){
            node.resultType = leftType;
        }else if(rightType.canCast(leftType)){
            node.resultType = rightType;
        }else {
            throw new AlephException("incompatible types %s & %s for \n%s\n%s\n%s"
                                        .format(leftType.toPrintable,
                                                rightType.toPrintable,
                                                node.left.toPretty,
                                                node.op,
                                                node.right.toPretty));
        }
        return node;
    }

    CallNode visit(CallNode node, AlephTable table)
    {
        node = DefaultProvider!(Provider, Args).visit(node, table);
        node.resultType = node.resultType.match(
            (UnknownType _) =>
                node.toCall.resultType.match(
                    (FunctionType ftype) => ftype.returnType,
                    (){ throw new AlephException("unable to call non-function of type %s in \n%s"
                                                    .format(node.resultType, node.toPretty)); }
                )
            ,
            (TypeofType t){
                if(!t.isResolved){
                    t.node = t.node.visit(table);
                }
                return t.node.resultType;
            },
            emptyFunc!Type
        );
        return node;
    }

    IdentifierNode visit(IdentifierNode node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("identifier %s not defined".format(node.name)));
        node.resultType.match(
            (UnknownType t) => node.resultType = sym.type, 
            (TypeofType t){
                if(!t.isResolved){
                    t.node = t.node.visit(table);
                }
                sym.type = t.node.resultType;
                node.resultType = sym.type;
            },
            emptyFunc!Type
        );
        return node;
    }

    T visit(T)(T t, Args args)
    {
        return cast(T)DefaultProvider!(Provider, Args).visit(t, args);
    }
};
