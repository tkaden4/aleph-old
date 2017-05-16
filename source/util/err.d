module util.err;

import std.string;

public {
    auto errorScope(ExceptionName, T)(in string sname, T fun)
    {
        try{
            static if(is(ReturnType!fun == void)){
                fun();
            }else{
                return fun();
            }
        }catch(ExceptionName err){
            throw new ExceptionName("%s error:\n\t%s".format(sname, err.msg));
        }
    }

    auto alephErrorScope(T)(in string sname, T fun){
        import AlephException;
        static if(is(ReturnType!fun == void)){
            errorScope!AlephException(sname, fun);
        }else{
            return errorScope!AlephException(sname, fun);
        }
    }
};
