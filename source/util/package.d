module util;

public {
    import util.match;

    // map the value of a tuple
    auto map(T, V, alias f)(Tuple!(T, V) t)
    {
        return f(t);
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
    auto if_then(alias func, T)(T t, bool val)
    {
        if(val){
            t.then!func;
        }
        return t;
    }
}
