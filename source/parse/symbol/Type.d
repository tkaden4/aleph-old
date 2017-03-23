module parse.symbol.Type;

interface TypeVisitor {
    void invoke(Type t);
};

interface Type {
    void visit(TypeVisitor tv);
};

class FunctionType : Type {
    void visit(TypeVisitor tv){ tv.invoke(this); }
    auto getReturnType() pure
    {
        return this.return_type;
    }
    auto getParameterTypes() pure
    {
        return this.param_types;
    }
private:
    Type return_type;
    Type[] param_types;
};
