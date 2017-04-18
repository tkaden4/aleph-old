module syntax.builders.variable;

public template variableClass(Type, Expression){
    private void initv(string name, Type t, Expression init=null)
    {
        this.name = name;
        this.type = t;
        this.init = init;
    }
    
    string name;
    Type type;
    Expression init;
};
