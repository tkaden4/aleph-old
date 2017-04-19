module util.match;

import std.traits;
import std.string;

// Visit a value based on it's runtime type
// if it doesnt match any, throw an exception
// TODO only match on concrete classes
public auto match(T, Args...)(T value, Args args)
{
    foreach(x; args){
        if(auto v = cast(Parameters!x[0])value){
            return x(v);
        }
    }
    // TODO improve error handling
    throw new Exception("Could not visit %s".format(value));
}
