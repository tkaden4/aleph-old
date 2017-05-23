import std.c.stdio

proc main = {
    let x = \y: *const char, g: int -> { y }
    puts(x("Hello, world"))
}
