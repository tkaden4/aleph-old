abil Iterate[T] {
    proc next() -> T
};

proc map[S, U, T: Iterate[U]](x: T, fn: U -> S) -> Iterate[S] = {
    proc() = fn(x.next())
}
