module syntax.common.variable;

public template variableClass(Type, Expression){
    private void initv(in string name, Type t, Expression initl=null)
    {
        this.name = name;
        this.type = t;
        this.initVal = initl;
    }
    
    string name;
    bool external;
    Type type;
    Expression initVal;
};
