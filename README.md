# Aleph #

Aleph is a high level programming language intended for use in
systems and embedded development. It features static typing,
generics, first class functions, and an ANSI C99 output.
It emphasizes ease of use, C compatibility, and efficiency.

## Features ##
- First-Class Functions
- Template Programming
- Rich Standard Library
- C99 Output

## Examples ##

A basic "Hello, World!" program
<pre>
// Import the C IO library
import std.c.stdio;
// Main procedure definition
proc main() -> int = {
    // call the C puts(const char *) function
    puts("Hello, World!");
    // return 0
    0
}
</pre>
