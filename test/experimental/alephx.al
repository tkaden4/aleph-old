
meta operator proc `->`(varlist: __Declaration[], body: __Expression,
                        scopectx: __Scope, ctx: __Compiler) {
    let newFunction =
            __Procedure(scope.uniqueName(), body.dType,
                                            varlist.map(__Expression::rType),
                                            body);
    ctx.callScope.addDeclaration(newFunction);
    newFunction
}

proc main {
    let x = x -> x
}
