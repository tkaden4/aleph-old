import std.c.stdio

proc map[S, U](s: S, fun: S -> U) -> U = fun(s)

proc prepend[S, U](s: S, u: U) = (u, s)

proc main() -> int = {
    map[int, int](0, \x = x)
    0.map(\x = x*2).prepend("%d").into(printf)
}
