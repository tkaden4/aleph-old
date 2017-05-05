import std.c.stdio

struct Val[T] {
    x: T
};

// extension function (may be called with dot notation)
proc Val[T].print(x: &const Val[T]) -> void = {
    printf("%d", x.x)
}

proc main() = {
    let value = Val { x = 6 }
    value.print()
    0
}
