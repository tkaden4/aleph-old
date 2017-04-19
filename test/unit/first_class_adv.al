proc add(a: int) = a
proc bar = add
proc foo = bar
proc fubar = foo
proc fubar2 = fubar
proc fubar3 = fubar2
proc fubar4 = fubar3
proc fubar5 = fubar4

proc main = {
    fubar2()()()()(8)
    0
}
