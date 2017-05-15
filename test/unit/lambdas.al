import std.c.stdio

proc main = {
    let x = \y: *const char -> y
    puts(x("Hello, world"))
}
