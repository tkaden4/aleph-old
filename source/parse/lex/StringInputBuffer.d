module parse.lex.StringInputBuffer;

import parse.lex.LexerInputBuffer;
import parse.lex.Token;

public class StringInputBuffer : LexerInputBuffer {
public:
    this(in string str, in string filename="string buffer")
    {
        this.buffer = str;
        this.name = filename;
        this.index = 0;
        this.col_no = 0;
        this.line_no = 0;
    }

    SourceLocation getLocation() const
    {
        return SourceLocation(this.name, this.line_no, this.col_no);
    }

    char next()
    {
        if(!this.hasNext){
            return '\0';
        }
        const char c = this.buffer[this.index++];
        ++this.col_no;
        if(c == '\n'){
            ++this.line_no;
            this.col_no = 0;
        }
        return c;
    }

    bool hasNext() pure
    {
        return this.index < this.buffer.length;
    }
private:
    string name;
    string buffer;
    size_t index;

    size_t col_no;
    size_t line_no;
};
