module util.err;

import std.string;

public {
    auto errorScope(string sname, ExceptionName, alias fun)()
    {
        try{
            static if(is(ReturnType!fun == void)){
                fun();
            }else{
                return fun();
            }
        }catch(ExceptionName err){
            throw new ExceptionName("%s error: %s".format(sname, err.msg));
        }
    }

    auto alephErrorScope(string sname, alias fun)(){
        import AlephException;
        static if(is(ReturnType!fun == void)){
            errorScope!(sname, AlephException, fun);
        }else{
            return errorScope!(sname, AlephException, fun);
        }
    }
};
