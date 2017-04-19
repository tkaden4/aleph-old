proc add = 8
proc bar = add()
proc foo = bar()

proc main = {
    foo()
    0
}
