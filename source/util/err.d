module util.err;

import std.string;
import util.AlephException;

public {
    mixin template easyException(string name)
    {
        import std.exception;
        mixin(" public class " ~ name ~ " : Exception {
                    mixin basicExceptionCtors;
                };");
    }

    auto errorScope(ExceptionName, T)(lazy string sname, T fun)
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

    auto alephErrorScope(T)(lazy string sname, T fun){
        static if(is(ReturnType!fun == void)){
            errorScope!AlephException(sname, fun);
        }else{
            return errorScope!AlephException(sname, fun);
        }
    }
};
