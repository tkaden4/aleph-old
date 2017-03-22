module parse.Token;

struct SourceLocation {
    string filename;
    size_t line_no;
    size_t col_no;
};

alias TokenType = Token.Type;

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
        IF,
        ELSE,
        SEMI,
        COLON,
        LBRACE,
        RBRACE,
        LPAREN,
        RPAREN,
        MINUS,
        RARROW,
        FUNC,
        STAR,
        GT,
        LT,
        EQ,
        GTEQ,
        LTEQ,
        REM,
        ID
    };
    
    string lexeme;
    Type type;
    SourceLocation location;

    string toString()
    {
        import std.string;
        return "Token(\"%s\", %s) l:%u, c:%u"
                    .format(this.lexeme, this.type, 
                            this.location.line_no,
                            this.location.col_no);
    }
};
