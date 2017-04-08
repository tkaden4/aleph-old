// this is an external declaration of C's printf() function

extern import "stdio.h"
extern proc printf(const char[]) -> void

proc fizz_buzz(n: int) -> void = {
    if n > 0 then fizz_buzz(n - 1)
    else return
    if n % 5 then printf("Fizz")
    if n % 3 then printf("Buzz")
}

proc main = {
    fizz_buzz(100)
    0
}
