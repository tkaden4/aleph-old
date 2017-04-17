source/syntax/transform/transform.d(82,18): Error: no property 'children' for type 'syntax.tree.ExpressionNode.ExpressionNode'
/usr/include/dlang/dmd/std/algorithm/iteration.d(871,10): Error: template instance syntax.transform.transform.visit.each!((x)
{
x.match((ProcDeclNode proc)
{
top ~= proc.visit(table, tab);
}
, (ASTNode node)
{
throw new CTreeException("Invalid Top-Level Declaration");
}
);
}
).isRangeUnaryIterable!(StatementNode[]) error instantiating
/usr/include/dlang/dmd/std/algorithm/iteration.d(890,9):        instantiated from here: isRangeIterable!(StatementNode[])
source/syntax/transform/transform.d(63,18): Error: template syntax.transform.transform.visit.each!((x)
{
x.match((ProcDeclNode proc)
{
top ~= proc.visit(table, tab);
}
, (ASTNode node)
{
throw new CTreeException("Invalid Top-Level Declaration");
}
);
}
).each cannot deduce function from argument types !()(StatementNode[]), candidates are:
/usr/include/dlang/dmd/std/algorithm/iteration.d(889,10):        syntax.transform.transform.visit.each!((x)
{
x.match((ProcDeclNode proc)
{
top ~= proc.visit(table, tab);
}
, (ASTNode node)
{
throw new CTreeException("Invalid Top-Level Declaration");
}
);
}
).each(Range)(Range r) if (isRangeIterable!Range && !isForeachIterable!Range)
/usr/include/dlang/dmd/std/algorithm/iteration.d(913,10):        syntax.transform.transform.visit.each!((x)
{
x.match((ProcDeclNode proc)
{
top ~= proc.visit(table, tab);
}
, (ASTNode node)
{
throw new CTreeException("Invalid Top-Level Declaration");
}
);
}
).each(Iterable)(auto ref Iterable r) if (isForeachIterable!Iterable)
/usr/include/dlang/dmd/std/algorithm/iteration.d(931,10):        syntax.transform.transform.visit.each!((x)
{
x.match((ProcDeclNode proc)
{
top ~= proc.visit(table, tab);
}
, (ASTNode node)
{
throw new CTreeException("Invalid Top-Level Declaration");
}
);
}
).each(Iterable)(auto ref Iterable r) if (!isRangeIterable!Iterable && !isForeachIterable!Iterable && __traits(compiles, Parameters!(Parameters!(r.opApply))))
/usr/include/dlang/dmd/std/algorithm/iteration.d(943,10):        syntax.transform.transform.visit.each!((x)
{
x.match((ProcDeclNode proc)
{
top ~= proc.visit(table, tab);
}
, (ASTNode node)
{
throw new CTreeException("Invalid Top-Level Declaration");
}
);
}
).each(Range)(Range range) if (!isRangeIterable!Range && !isForeachIterable!Range && __traits(compiles, typeof(range.front).length))
source/gen/CGenerator.d(49,13): Error: no property 'children' for type 'syntax.ctree.CTopLevelNode.CTopLevelNode'
source/gen/CGenerator.d(72,14): Error: no property 'eachall' for type 'syntax.ctree.CBlockStatementNode.CBlockStatementNode'
dmd failed with exit code 1.
make: *** [makefile:2: build] Error 2
