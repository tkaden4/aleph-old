struct Point {
    x: long
    y: long
}

proc Point.new(x: long, y: long) = {
    this.x = x
    this.y = y
}

proc main = {
    let point = Point(8, 8)
}
