//extern import "stdio.h"

//extern proc printf(*const char, ...) -> int
//extern proc putchar(int) -> int

proc identity(a: int) -> int = {
    //printf("%d", a)
    //putchar(10)
    a
}

proc main -> int = {
    let k: (int) -> int = identity
    k(9999)
    0
}
