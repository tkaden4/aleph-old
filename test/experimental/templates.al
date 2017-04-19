import std.c.stdio

proc map[S, U](s: S, fun: S -> U) -> U = fun(s)

proc main() -> int = {
    map[int, int](0, proc(x: int) -> int = x)
}
