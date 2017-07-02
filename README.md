# Aleph #

Aleph is a high level programming language intended for use in
systems development. It features static typing,
generics, first class functions, and an ANSI C99 output.
It emphasizes ease of use, C compatibility, and efficiency.

## Examples ##

### Hello, World! ###
<pre>
// Import the C IO library
import std.c.stdio;
// Main procedure definition
proc main() -> int {
    // call the C puts(const char *) function
    puts("Hello, World!");
    // return 0
    0
}
</pre>

### Type Inference ###
<pre>
import std.c.stdio

proc hello = "Hello";   // Semicolon is optional, type inferred as \*const char

proc main {       // Parameters and return type optional
    puts(hello())
    0
}
</pre>

### First-Class Functions ###
<pre>
proc add_two(a: int) = a + 2

proc map_sum(a: int, b: int, fn: int -> int) {
    if a == b then fn(b)
    else fn(a) + map_sum(a+1, b, fn)
}

import std.c.stdio;

proc main {
    printf("%d\n", map_sum(0, 3, add_two))
    0
}
</pre>

### Compound Data Types ###
<pre>
import std.c.stdio

struct Point {
    x: long
    y: long
}

proc main {
    let point = Point { x = 0; y = 0 }
    printf("x: %d, y: %d", point.x, point.y)
    0
}
</pre>
