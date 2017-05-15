module util.match;

import std.traits;
import std.string;
import std.meta;
import util.meta;
import std.exception;

/* Visit a value based on its runtime type
 * TODO match patterns
 */

public class MatchException : Exception {
    mixin basicExceptionCtors;
};

public auto match(T, Args...)(T value, Args args)
{
    static assert(args.length > 0, "no match branches");
    static if(arity!(args[$-1]) == 0){
        alias handler = AliasSeq!(args[$-1]);
        alias match_funs = args[0..$-1];
    }else{
        alias handler = AliasSeq!();
        alias match_funs = args;
    }
    alias common = GreatestCommonType!(WithoutNull!(ReturnTypes!match_funs));

    foreach(x; match_funs){
        if(auto v = cast(Parameters!x[0])value){
            static if(is(common == void)){
                x(v);
                return;
            }else{
                return cast(common)x(v);
            }
        }
    }
    static if(handler.length){
        alias handlerRet = ReturnType!handler;
        static if(is(handlerRet == void)){
            handler[0]();
            throw new MatchException("reached end of visitor %s".format(value));
        }else{
            return handler[0]();
        }
    }else{
        throw new MatchException("could not match on %s".format(value));
    }
}
