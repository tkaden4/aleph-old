proc foo -> int = 8
proc foo_ret -> () -> int = foo
proc foo_ret_inf = foo
proc foo_ret_ret -> () -> () -> int = foo_ret
proc ident(a: int) = a
proc foo_ret_ret_ret -> int -> int = ident 

proc main() -> int = {
    foo_ret()()
    0
}
