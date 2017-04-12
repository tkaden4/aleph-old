module util;

public {
    import util.match;
    import std.typecons;

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

    // map the value of a tuple
    auto map(T, V, alias f)(Tuple!(T, V) t)
    {
        return f(t);
    }

    auto apply(alias f, T)(T t)
    {
        if(t){
            f(t);
        }
    }

    auto use(alias f, T)(T t)
    {
        if(t){
            return f(t);
        }
        return null;
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
