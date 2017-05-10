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
    alias common = GreatestCommonType!(WithoutNull!(ReturnTypes!Args));

    foreach(x; args){
        if(auto v = cast(Parameters!x[0])value){
            static if(is(common == void)){
                x(v);
                return;
            }else{
                return cast(common)x(v);
            }
        }
    }
    throw new MatchException("Could not visit %s".format(value));
}
