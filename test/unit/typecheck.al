import std.c.stdio

proc main() -> int = {
    let k: *const char = "hello, world"
    puts(k)
    0
}
