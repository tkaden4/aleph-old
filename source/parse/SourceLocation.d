module parse.SourceLocation;

import std.string : format;

public struct SourceLocation {
    string filename;
    size_t line_no;
    size_t col_no;

    string toString() const
    {
        return "SourceLocation(%s, l:%s, c:%s)".format(this.filename, this.line_no, this.col_no);
    }
};

