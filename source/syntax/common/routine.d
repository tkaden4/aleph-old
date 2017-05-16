module syntax.common.routine;

mixin template routineNodeClass(Type, BodyExpression, Parameter)
{
    public:
    protected void init(in string name, Type ret, Parameter[] params, BodyExpression b=null)
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

mixin template routineNode(alias Name, Type, BodyNode, alias Parent)
{
    public class Name : Parent {
        mixin routineNodeClass!(Type, BodyNode);

        this(in string _name, Type ret, Parameter[] params, BodyNode b=null)
        {
            this.init(_name, ret, params, b);
        }
    };
}
