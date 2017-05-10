module parse.lex.Token;

import std.string;
public import parse.util.SourceLocation;
public import parse.util.StringView;

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
        TYPEOF,
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
        DOT,
        /* Etc. */
        ID,
        IMPORT,
        STRUCT,
        VARARG
    };
    
    StringView _lexeme;
    Type type;
    SourceLocation location;

    this(in string _lexeme, Type type, in SourceLocation loc)
    {
        this._lexeme = new StringView(loc, _lexeme.ptr, _lexeme.length);
        this.type = type;
        this.location = loc;
    }


    @property auto lexeme()
    {
        return this._lexeme.value;
    }

    string toString()
    {
        import std.string;
        return "Token(\"%s\", %s) l:%u, c:%u".format(this.lexeme, this.type, 
                                                     this.location.line_no,
                                                     this.location.col_no);
    }
};
