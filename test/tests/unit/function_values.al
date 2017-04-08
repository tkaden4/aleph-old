proc identity(a: int) = a
proc main = {
    let k: (int) -> int = identity
    k(0)
    0
}
