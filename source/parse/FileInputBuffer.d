module parse.FileInputBuffer;

import std.stdio;
import std.file;

import parse.LexerInputBuffer;
import parse.Token;

class FileInputBuffer : LexerInputBuffer {
public:
    this(string filename)
    {
        this.filename = filename;
        this.file_buff = readText(filename);
        this.index = 0;

        this.line_no = 0;
        this.col_no = 0;
    }
    char next()
    {
        return this.read();
    }
    SourceLocation getLocation() pure
    {
        return SourceLocation(this.filename, this.line_no, this.col_no);
    }
    bool hasNext() pure
    {
        return this.index < this.file_buff.length;
    }
private:
    char read()
    {
        if(!this.hasNext()){
            throw new Exception("Reached end of buffer");
        }else{
            char ret = this.file_buff[this.index++];
            ++this.col_no;
            if(ret == '\n'){
                ++this.line_no;
                this.col_no = 0;
            }
            return ret;
        }
    }
private:
    string filename;
    string file_buff;
    size_t index;

    size_t col_no;
    size_t line_no;
};
