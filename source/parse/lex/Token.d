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
        EXTERN,
        STATIC,
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
        NTEQ,
        REM,
        DEC,
        INC,
        /* Etc. */
        ID,
        EOS
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

    bool opEquals(in Token o) pure
    {
        return this.type == o.type;
    }
};

unittest
{
    assert(Token("foo", TokenType.ID) == Token("bar", TokenType.ID));
}
