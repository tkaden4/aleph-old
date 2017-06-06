import std.c.stdio

struct ReturnsItself {
    foo: (int, int) -> int
    default: int
}

proc call(x: ReturnsItself) = x.foo(x.default, 0)

proc main {
    let function = Funct { x = identity }
    //printf("%d", x.x(8))
    0
}
