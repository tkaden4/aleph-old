module semantics.type.FunctionType;

import semantics.type.Type;

public class FunctionType : Type {
public:
    this(Type ret, Type[] param)
    {
        this.return_type = ret;
        this.param_types = param;
    }

    invariant
    {
        foreach(x; this.param_types){
            assert(x, "Param is null");
        }
        assert(this.return_type, "Return is null");
    }

    @property auto returnType()
    {
        return this.return_type;
    }

    @property auto parameterTypes()
    {
        return this.param_types;
    }

    @property void returnType(Type t)
    {
        this.return_type = t;
    }

    override string toString()
    {
        import std.string;
        string params;
        foreach(i, x; this.param_types){
            if(i == this.param_types.length - 1){
                params ~= "%s".format(x);
                break;
            }
            params ~= "%s, ".format(x);
        }
        return "((%s) -> %s)".format(params, this.return_type);
    }
private:
    Type return_type;
    Type[] param_types;
};
