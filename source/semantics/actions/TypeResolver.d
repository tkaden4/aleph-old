module semantics.actions.TypeResolver;

/* 
 * Performs all type inferencing
 */

import std.typecons;
import std.range;
import std.algorithm;
import std.stdio;
import std.string;
import std.exception;

import syntax;
import semantics;
import util;

public auto resolveTypes(Tuple!(Program, AlephTable) t)
{
    return t.expand.resolveTypes;
}

public auto resolveTypes(Program node, AlephTable table)
{
    return alephErrorScope("type resolver", {
        node = TypeResolveProvider!(TypeResolveProvider, AlephTable).visit(node, table);
        return tuple(node, table);
    });
}

template TypeResolveProvider(alias Provider, Args...)
{
    auto inferTypes(Args...)(AlephTable table, Args args)
    {
        alias resolveType =
            (x, y) =>
                x.match(
                    (UnknownType _) => y,
                    (TypeofType t) => t.isResolved ?
                                      t.node.resultType :
                                      (t.node = t.node.visit(table)).resultType,
                    (FunctionType fn) =>
                        fn,
                    /* TODO
                        y.match(
                            emptyFunc!FunctionType,
                            (){ throw new Exception("Internal type-resolution error"); }
                        ).use!((asFun){
                            auto ret = table
                                    .inferTypes(
                                        tuple(fn.returnType, asFun.returnType),
                                    );

                        }),
                        */
                    identity!Type
                );
        auto res = [args].map!(x => resolveType(x.expand)).array;
        static if(Args.length > 1){
            return res;
        }else{
            return res[0];
        }
    }


    VarDecl visit(VarDecl node, AlephTable table)
    {
        node = DefaultProvider!(Provider, Args).visit(node, table);
        auto sym = table.find(node.name).err(new Exception("Symbol %s not defined".format(node.name)));

        table.inferTypes(tuple(node.type, node.initVal.resultType))
             .then!((x){ sym.type = x; node.type = x; });

        return node;
    }

    Block visit(Block node, AlephTable table)
    {
        node = DefaultProvider!(Provider, Args).visit(node, table);
        if(node.children.empty){
            node.resultType = PrimitiveType.Void;
        }else{
            node.resultType = node.children.back.use!(x => x.resultType).or(PrimitiveType.Void);
        }
        return node;
    }

    IfExpression visit(IfExpression node, AlephTable table)
    {
        node.ifexp = node.ifexp.visit(table);
        node.thenexp = node.thenexp.visit(table);
        if(node.elseexp){
            node.elseexp = node.elseexp.visit(table);
        }
        node.resultType = node.thenexp.resultType;
        return node;
    }

    ProcDecl visit(ProcDecl node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("Function %s not defined".format(node.name)));
        sym.match(
            (FunctionSymbol f){
                node.bodyNode = node.bodyNode.visit(f.bodyScope);
                table.inferTypes(tuple(node.returnType, node.bodyNode.resultType))
                     .then!((x){ node.returnType = x;
                                 sym.type = node.functionType; });
            },
            (){ throw new AlephException("no function named %s".format(node.name)); }
        );
        return node;
    }

    auto visit(BinaryExpression node, AlephTable table)
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

    auto visit(Call node, AlephTable table)
    {
        node = DefaultProvider!(Provider, Args).visit(node, table);
        auto t = 
            //TODO fix
            table.inferTypes(
                tuple(node.resultType,
                      node.toCall.resultType.use!(x => cast(FunctionType)x).returnType),
            );
        node.resultType = t;
        return node;
    }

    auto visit(Identifier node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("identifier %s not defined".format(node.name)));
        table.inferTypes(tuple(node.resultType, sym.type))
             .then!((t){ node.resultType = t;
                         sym.type = t; });
        return node;
    }

    T visit(T)(T t, Args args)
    {
        return DefaultProvider!(Provider, Args).visit(t, args);
    }
};
