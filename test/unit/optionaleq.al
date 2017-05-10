proc foo(a: int) -> typeof(0) {
    a
}

proc bar -> typeof(0) = 0

proc main = foo(bar())
