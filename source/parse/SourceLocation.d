module parse.SourceLocation;

import std.string : format;

public struct SourceLocation {
    const(string) filename;
    const(size_t) line_no;
    const(size_t) col_no;

    this(in string filename, size_t lineno, size_t colno)
    {
        this.filename = filename;
        this.line_no = lineno;
        this.col_no = colno;
    }

    string toString() const
    {
        return "SourceLocation(%s, l:%s, c:%s)".format(this.filename, this.line_no, this.col_no);
    }
};

