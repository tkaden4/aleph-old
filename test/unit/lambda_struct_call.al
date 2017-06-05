import std.c.stdio

struct Funct {
    x: (int) -> int
}

proc main {
    let x = Funct { x = identity }
    printf("%d", x.x(8))
    0
}
