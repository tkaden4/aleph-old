import std.c.stdio

proc map[S, U](s: S, fun: S -> U) -> U = fun(s)

proc then[T, V](t: T, fun: T -> V) -> T = { fun(); t }

proc main() -> int = {
    map[int, int](0, \x = x)
}
