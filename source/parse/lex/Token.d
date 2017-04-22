module parse.lex.Token;

import std.string;

public struct SourceLocation {
    string filename;
    size_t line_no;
    size_t col_no;

    string toString() const
    {
        return "SourceLocation(%s, l:%s, c:%s)".format(this.filename, this.line_no, this.col_no);
    }
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
        THEN,
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
        IMPORT,
        STRUCT,
        VARARG
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
