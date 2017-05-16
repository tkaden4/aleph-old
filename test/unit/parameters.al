proc first(k: int, b: int) -> int = k

proc identity(j: int) = j

proc idne(f: (int) -> int) = f(8)

proc main() -> int = {
    first(idne(identity), 2)
    0
}
