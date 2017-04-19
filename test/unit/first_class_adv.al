proc add -> int = 8
proc bar -> int = add()
proc foo -> int = bar()

proc main -> int = {
    bar()
    0
}
