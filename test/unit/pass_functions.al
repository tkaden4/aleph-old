proc ident(a: void -> int) = a()

proc main -> int = {
    ident(main)
    0
}
