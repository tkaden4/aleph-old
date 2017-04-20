extern import "stdio.h"

extern proc putchar(int) -> int
extern proc puts(*const char) -> int

proc main = {
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
    puts("Hello, World!")
    0
}
