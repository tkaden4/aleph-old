module parse.lex.Token;

public struct SourceLocation {
    string filename;
    size_t line_no;
    size_t col_no;
};

public alias TokenType = Token.Type;

public struct Token {
public:
    enum Type {
        EOF,
        EOS,
        /* Literals */
        INTEGER,
        FLOAT,
        CHAR,
        STRING,
        /* Keywords */
        PROC,
        FUNC,
        LET,
        IF,
        ELSE,
        /* Storage Classes */
        EXTERN,
        STATIC,
        /* Qualifiers */
        CONST,
        /* Punctuation */
        SEMI,
        COLON,
        LBRACE,
        RBRACE,
        LPAREN,
        RPAREN,
        RARROW,
        STAR,
        COMMA,
        /* operators */
        MINUS,
        PLUS,
        DIV,
        BANG,
        EQ,
        GT,
        LT,
        EQEQ,
        GTEQ,
        LTEQ,
        NEQ,
        REM,
        DEC,
        INC,
        /* Etc. */
        ID,
        IMPORT
    };
    
    string lexeme;
    Type type;
    SourceLocation location;

    string toString() const
    {
        import std.string;
        return "Token(\"%s\", %s) l:%u, c:%u".format(this.lexeme, this.type, 
                                                     this.location.line_no,
                                                     this.location.col_no);
    }
};
