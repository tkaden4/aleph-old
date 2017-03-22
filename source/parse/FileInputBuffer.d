module parse.FileInputBuffer;

import std.stdio;
import std.file;

import parse.StringInputBuffer;
import parse.Token;

class FileInputBuffer : StringInputBuffer {
public:
    this(string filename)
    {
        super(readText(filename));
    }
};
