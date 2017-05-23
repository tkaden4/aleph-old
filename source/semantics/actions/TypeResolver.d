module semantics.actions.TypeResolver;

/* 
 * Performs all type inferencing
 */

import std.typecons;
import std.range;
import std.algorithm;
import std.stdio;
import std.string;

import syntax.tree;
import syntax.print;
import semantics;
import syntax.visit.Visitor;
import AlephException;
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
        new TypeResolver().dispatch(node, table);
        return tuple(node, table);
    });
}


private class TypeResolver : Visitor!(void, AlephTable) {
protected:
    auto evaluateType(N)(N def, Type t, AlephTable table)
    {
        return t.match(
            (UnknownType _){
                return def.resultType;
            },
            (TypeofType t){
                if(!t.isResolved){
                    super.visit(t.node, table);
                }
                return t.node.resultType;
            },
            emptyFunc!Type
        );
    }

    override void visit(ref VarDeclNode node, AlephTable table)
    {
        super.visit(node, table);
        auto sym = table.find(node.name).err(new Exception("Symbol %s not defined".format(node.name)));
        auto type = this.evaluateType(node.initVal, node.type, table);
        sym.type = type;
        node.type = type;
    }

    override void visit(ref BlockNode node, AlephTable table)
    {
        super.visit(node, table);
        node.resultType = node.children.back.use!(x => x.resultType).or(PrimitiveType.Void);
    }

    override void visit(ref IfExpressionNode node, AlephTable table)
    {
        super.visit(node.ifexp, table);
        super.visit(node.thenexp, table);
        if(node.elseexp){
            super.visit(node.elseexp, table);
        }
        node.resultType = node.thenexp.resultType;
    }

    override void visit(ref ProcDeclNode node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("Function %s not defined".format(node.name)));
        sym.match(
            (FunctionSymbol f){
                super.visit(node.bodyNode, f.bodyScope);
                auto type = this.evaluateType(node.bodyNode, node.returnType, table);
                node.returnType = type;
                sym.type = node.functionType;
            },
            (){ throw new AlephException("no function named %s".format(node.name)); }
        );
    }

    override void visit(ref BinOpNode node, AlephTable table)
    {
        super.visit(node.left, table);
        super.visit(node.right, table);

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
    }

    override void visit(ref CallNode node, AlephTable table)
    {
        auto x = node.toCall;
        super.visit(x, table);
        node.toCall = x;
        foreach(arg; node.arguments){
            super.visit(arg, table);
        }
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
                    super.visit(t.node, table);
                }
                return t.node.resultType;
            },
            emptyFunc!Type
        );
    }

    override void visit(ref IdentifierNode node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("identifier %s not defined".format(node.name)));
        node.resultType.match(
            (UnknownType t) => node.resultType = sym.type, 
            (TypeofType t){
                if(!t.isResolved){
                    super.visit(t.node, table);
                }
                sym.type = t.node.resultType;
                node.resultType = sym.type;
            },
            emptyFunc!Type
        );
    }
};