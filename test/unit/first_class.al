proc foo -> int = 8
proc foo_ret -> void -> int = foo
proc foo_ret_inf = foo
proc foo_ret_ret -> void -> void -> int = foo_ret
proc ident(a: int) = a
proc foo_ret_ret_ret -> const int -> int = ident 

proc main() -> int = {
    foo_ret()()
    0
}
