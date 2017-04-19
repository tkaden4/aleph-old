proc identity(a: int) -> int = a
proc main -> int = {
    let k: (int) -> int = identity
    k(0)
    0
}
