proc identity(a: int) = a
proc fidentity(a: int -> int) = a

proc apply(a: int -> int, b: int) = a(b)
proc applyapply(a: (int -> int) -> int, k: int -> int, b: int) = a(k)

proc main = {
    applyapply(apply, identity, 0)
}
