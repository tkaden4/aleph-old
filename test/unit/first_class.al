proc foo -> int = 8
proc foo_ret -> (void) -> (int) -> void = foo

proc main() = {
    foo_ret()()
    0
}
