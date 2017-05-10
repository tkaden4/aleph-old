proc identity(a: int) = a
proc fidentity(a: int -> int) = a

proc apply(a: int -> int, b: int) -> int = a(b)
proc applyapply(a: (int -> int, int) -> int, k: int -> int, b: int) = a(k, b)

proc main = {
    let testerino = applyapply
    testerino(apply, identity, 0)
}
