proc foo -> int = 8
proc foo_ret -> (void) -> int = foo

proc main() -> int = {
    foo_ret()()
    0
}
