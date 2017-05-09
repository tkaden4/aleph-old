import std.c.stdio

extern proc puts(*const char) -> int

proc main() -> int = {
    let k: *const char = "hello, world"
    puts(k)
    0
}
