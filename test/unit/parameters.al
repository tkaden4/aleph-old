proc first(a: int, b: int) -> int = a

proc identity(a: int) = a

proc idne(a: int -> int) = a(8)

proc main() -> int = {
    first(idne(identity), 2)
    0
}
