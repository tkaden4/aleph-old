module util;

import std.typecons;
import std.traits;
import std.range;
import std.algorithm;

public {
    import util.err;
    import util.meta;
    import util.match;
    import util.AlephException;

    static auto instance(T, Args...)(Args args)
    {
        static T ins = null;
        if(!ins){
            ins = new T(args);
        }
        return ins;
    }

    auto maybeArgsCall(alias fun, Args...)(Args args)
    {
        static if(__traits(compiles, fun(args))){
            fun(args);
        }else{
            fun();
        }
    }

    auto between(T)(bool pred, T a, T b)
    {
        return pred ? a : b;
    }

    auto construct(Type, Params...)(Params params)
    {
        return new Type(params);
    }

    auto not(T)(T t){
        return !t;
    }

    auto headLast(alias first, alias last, T)(T range)
    {
        foreach(i, x; range){
            if(i == range.length - 1){
                last(x);
                break;
            }
            first(x);
        }
    }

    void raise(T)(T e)
    {
        throw e;
    }

    auto err(T, Ex)(T t, Ex e)
    {
        if(!t){
            throw e;
        }
        return t;
    }

    T getOrThrow(T)(Nullable!T n, const Exception ex) pure
    {
        if(n.isNull){
            throw ex;
        }
        return n.get;
    }

    auto foldOr(alias func, T, F)(T inRange, F defaultVal)
    {
        if(inRange.empty){
            return defaultVal;
        }
        return inRange.fold!func;
    }

    auto apply(alias f, T)(T t)
    {
        if(t){
            f(t);
        }
    }

    auto use(alias f, T)(T t)
    {
        static if(__traits(compiles, f())){
            alias fun = _ => f();
        }else{
            alias fun = f;
        }
        static if(__traits(compiles, !t)){
            if(t){
                return fun(t);
            }
            return null;
        }else{
            return fun(t);
        }
    }

    auto use_err(alias f, T, Ex)(T t, Ex e)
    {
        if(t){
            return f(t);
        }
        throw e;
    }

    auto or(T)(T t, T d)
    {
        if(t){
            return t;
        }
        return d;
    }

    // time a function
    auto time(string type, T)(T func)
    {
        import std.datetime;

        const auto start = Clock.currTime;
        func();
        return (Clock.currTime - start).total!type;
    }

    // applies a function to a T and returns the T
    // for chaining operations on a single type
    auto then(alias func, T)(T t)
    {
        static if(__traits(compiles, func())){
            func();
        }else{
            func(t);
        }
        return t;
    }

    // only applies a function based on a runtime boolean value
    auto if_then(alias func, T)(T t)
    {
        if(t){
            t.then!func;
        }
        return t;
    }
}
