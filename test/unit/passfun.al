proc identity(a: int) = a
proc fidentity(a: int -> int) = a

proc apply(a: int -> int, b: int) = a(b)
proc applyapply(a: (int -> int) -> int, k: int -> int, b: int) = a(k, b)
proc applyapplyapply(a: (int -> int) -> (int -> int) -> int -> int, k: int -> int, f: int) = a(k)(k)(f)

proc anotherfun(a: (int -> int) -> int -> int, b: int -> int) = a(b)
proc anotherfunfun(a: (int -> int) -> (int -> int) -> int -> int, b: (int -> int) -> int) = a(b)

proc multifun(a: (int -> int) -> int,
              b: int -> int -> int,
              c_: int, k_: int) = a(b(c_), k_)

proc main = {
    applyapplyapply()
    applyapply(apply, identity, 0)
}
