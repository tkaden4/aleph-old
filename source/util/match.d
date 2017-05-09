module util.match;

import std.traits;
import std.string;
import std.meta;
import util.meta;

// Visit a value based on it's runtime type
// if it doesnt match any, throw an exception
// TODO only match on concrete classes
/* get the return types of multiple functions */
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
    throw new Exception("Could not visit %s".format(value));
}
