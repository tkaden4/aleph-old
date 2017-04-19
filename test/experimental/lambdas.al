import std.c.stdio

proc main() -> int = {
    let print = proc(x: *const char) = puts(x)
    print("hello")
}
