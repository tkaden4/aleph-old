proc add(a: int) = a
proc bar = add
proc foo = bar
proc fubar = foo
proc fubar2 = fubar

proc main = {
    fubar2()()()()(8)
    0
}
