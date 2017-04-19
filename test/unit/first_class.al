proc foo -> int = 8
proc foo_ret -> void -> int = foo
proc foo_ret_inf = foo
proc foo_ret_ret -> void -> void -> int = foo_ret

proc main() -> int = {
    foo_ret()()
    0
}
