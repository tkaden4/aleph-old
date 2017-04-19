module syntax.builders.variable;

public template variableClass(Type, Expression){
    private void initv(string name, Type t, Expression initl=null)
    {
        this.name = name;
        this.type = t;
        this.initVal = initl;
    }
    
    string name;
    Type type;
    Expression initVal;
};
