extern import "stdio.h"
extern proc printf(*const char, ...) -> int

proc main = {
    printf("java %s", { "java" })
    0
}
