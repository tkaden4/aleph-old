extern import "stdio.h"

extern proc putchar(int) -> int
extern proc puts(*const char) -> int
extern proc printf(*const char, ...) -> int

proc print(x: *const char) -> int = {
    puts(x)
}

proc main = {
    printf("%d", 1)
/* TODO fix type promotion
    putchar(10)
    putchar('H')
    putchar('e')
    putchar('l')
    putchar('l')
    putchar('o')
    putchar(',')
    putchar(' ')
    putchar('W')
    putchar('o')
    putchar('r')
    putchar('l')
    putchar('d')
    putchar('!')
    putchar(10)
*/
    print("Hello, World!")
    0
}
