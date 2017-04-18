module syntax.builders.routine;

template routineNodeClass(Type, BodyExpression)
{
    public:
    struct Parameter {
        Type type;
        string name;
    };

    protected void init(string name, Type ret, Parameter[] params, BodyExpression b=null)
    { 
        this.name = name;
        this.returnType = ret;
        this.bodyNode = b;
        this.parameters = params;
    }

    string name;
    Type returnType;
    BodyExpression bodyNode;
    Parameter[] parameters;
}
