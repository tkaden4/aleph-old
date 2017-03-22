module parse.Token;

struct SourceLocation {
    string filename;
    size_t line_no;
    size_t col_no;
};

struct Token {
public:
    enum Type {
        EOF,
        INTEGER,
        FLOAT,
        CHAR,
        STRING,
        PROC,
        LET,
        SEMI,
        COLON,
        LBRACE,
        RBRACE,
        LPAREN,
        RPAREN,
        MINUS,
        RARROW,
        EQ,
        ID
    };
    
    this(string lexeme, Type type, SourceLocation loc)
    {
        this.lexeme = lexeme;
        this.type = type;
        this.location = loc;
    }

    string lexeme;
    Type type;
    SourceLocation location;
};
