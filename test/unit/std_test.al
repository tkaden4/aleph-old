//import std.c.stdio

extern proc printf(*const char, ...) -> int

proc printTo(x: int) = {
    printf("%d", x)
    x
}

proc main(argc: int, argv: **const char) = {
    printf("%d", printTo(8))
    printf("%d", printTo(8))
    0
}
