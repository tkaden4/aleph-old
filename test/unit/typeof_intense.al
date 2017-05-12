proc bar = 0
proc main = {
    let foo: typeof(bar) = bar
    let k: typeof(0) = foo()
    k
}
