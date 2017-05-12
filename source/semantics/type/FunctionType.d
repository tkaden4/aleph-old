module semantics.type.FunctionType;

import semantics.type.Type;
import AlephException;

import std.range;
import std.string;

public class FunctionType : Type {
public:
    this(Type ret, Type[] param, bool vararg=false)
    {
        this.return_type = ret;
        this.param_types = param;
        this.vararg = vararg;
    }

    invariant
    {
        assert(this.return_type);
        foreach(x; this.param_types){
            assert(x);
        }
    }

    @property auto returnType()
    {
        return this.return_type;
    }

    bool isVararg() pure
    {
        return this.vararg;
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
        if(this.isVararg){
            if(this.param_types.length > 0){
                params ~= ", ";
            }
            params ~= "...";
        }
        return "((%s) -> %s)".format(params, this.return_type);
    }

    override bool canCast(Type other)
    {
        import util;
        return other.match(
            (FunctionType type){
                if(type.parameterTypes.length != this.parameterTypes.length){
                    return false;
                }
                bool params = false;
                foreach(x; type.parameterTypes.zip(this.parameterTypes)){
                    params = x[0].canCast(x[1]);
                    if(!params){
                        return false;
                    }
                }
                return this.returnType.canCast(type.returnType);
            },
            (Type t) => false,
            (){ throw new AlephException("Could not cast to %s".format(other)); }
        );
    }

private:
    bool vararg;
    Type return_type;
    Type[] param_types;
};
