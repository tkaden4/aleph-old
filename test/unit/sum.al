import std.c.stdio

proc add_two(a: int) = a + 2

proc map_sum(a: int, b: int, fn: int -> int) {
    if a == b then fn(b)
    else fn(a) + map_sum(a+1, b, fn)
}

import std.c.stdio

proc main = {
    printf("%d\n", map_sum(0, 3, add_two))
    0
}
