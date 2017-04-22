module syntax.builders.routine;

mixin template routineNodeClass(Type, BodyExpression)
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

mixin template routineNode(alias Name, Type, BodyNode, alias Parent)
{
    public class Name : Parent {
        mixin routineNodeClass!(Type, BodyNode);

        this(string _name, Type ret, Parameter[] params, BodyNode b=null)
        {
            this.init(_name, ret, params, b);
        }
    };
}
