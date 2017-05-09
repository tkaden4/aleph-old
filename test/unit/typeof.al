extern proc puts(*const char) -> typeof(0)

proc returns_string -> typeof("") = "this is a frigging string"

proc main -> typeof(0) = {
    puts(returns_string())
    0
}
