module parse.lex.Lexer;

public import parse.lex.Token;
public import parse.lex.LexerInputBuffer;
public import parse.lex.LexerException;

import std.container;
import std.stdio;
import std.ascii;
import std.string;

private bool isIdBody(dchar c) pure
{
    return isAlpha(c) || isDigit(c) || c == '_';
}

private bool isIdStart(dchar c) pure
{
    return isAlpha(c) || c == '_';
}

public final class Lexer {
    import std.functional;
public:
    this(LexerInputBuffer input)
    {
        this.buff = input;
        if(!this.buff.hasNext){
            throw new LexerException("Lexer was provided an empty buffer");
        }
        this.la_buff ~= this.buff.next;
    }

    invariant
    {
        assert(this.buff);
    }

    Token *next()
    {
        if(!this.hasNext){
            return this.makeToken("EOS", Token.Type.EOS);
        }

        if(this.test((&isWhite).toDelegate)){
            while(this.test((&isWhite).toDelegate)){
                this.advance;
            }
            return this.next;
        }

        // Ignore comments
        if(this.test('/') && this.test('/', 1)){
            this.ignore(delegate(dchar c){
                return c != '\n';
            });
            this.match('\n');
            return this.next;
        }

        // Ignore multiline comments
        if(this.test('/') && this.test('*', 1)){
            this.advance;
            this.advance;
            while(!(this.test('*') && this.test('/', 1))){
                this.advance;
            }
            this.advance;
            this.advance;
            return this.next;
        }

        if(this.test("...")){
            this.advance;
            this.advance;
            this.advance;
            return this.makeToken("...", Token.Type.VARARG);
        }

        switch(this.la){
        /* Punctuation */
        case '{': return this.makeAndAdvance("{", Token.Type.LBRACE);
        case '}': return this.makeAndAdvance("}", Token.Type.RBRACE);
        case '(': return this.makeAndAdvance("(", Token.Type.LPAREN);
        case ')': return this.makeAndAdvance(")", Token.Type.RPAREN);
        case ';': return this.makeAndAdvance(";", Token.Type.SEMI);
        case ':': return this.makeAndAdvance(":", Token.Type.COLON);
        case ',': return this.makeAndAdvance(",", Token.Type.COMMA);
        /* Operators */
        case '%': return this.makeAndAdvance("%", Token.Type.REM);
        case '*': return this.makeAndAdvance("*", Token.Type.STAR);
        case '/': return this.makeAndAdvance("/", Token.Type.DIV);
        case '!': return this.makeAndAdvance("!", Token.Type.BANG);
        case '-': return this.lexMultiple('-', Token.Type.MINUS, '>', Token.Type.RARROW, '-', Token.Type.DEC);
        case '+': return this.lexMultiple('+', Token.Type.PLUS, '+', Token.Type.INC);
        case '=': return this.lexMultiple('=', Token.Type.EQ, '=', Token.Type.EQEQ);
        case '<': return this.lexMultiple('<', Token.Type.LT, '=', Token.Type.LTEQ);
        case '>': return this.lexMultiple('>', Token.Type.GT, '=', Token.Type.GTEQ);
        /* Etc. Rules */
        case '\"': return this.lexString;
        case '\'': return this.lexChar;
        case '_': return this.lexIdOrKeyword;
        default:
            if(this.test(toDelegate(&isIdStart))){
                return this.lexIdOrKeyword;
            }else if(this.test(toDelegate(&isDigit))){
                return this.lexNumber;
            }
            throw new LexerException("Couldn't match on character '%c' at %s"
                                        .format(this.la, this.buff.getLocation));
        }
    }

    bool hasNext()
    {
        return this.la != '\0';
    }
private:
    /* LEXER RULES */

    auto escape(char c) pure
    {
        switch(c){
        case 'n': return '\n';
        case 't': return '\t';
        case '\"': return '\"';
        case '\'': return '\'';
        case '\\': return '\\';
        default: return c;
        }
    }

    Token *lexIdOrKeyword()
    {
        string lexeme;
        while(this.test(toDelegate(&isIdBody))){
            lexeme ~= this.advance;
        }
        return this.handleKeyword(this.makeToken(lexeme, Token.Type.ID));
    }

    /* TODO handle floating-point numbers */
    Token *lexNumber()
    {
        string lexeme;
        while(this.test(toDelegate(&isDigit))){
            lexeme ~= this.advance;
        }
        return this.makeToken(lexeme, Token.Type.INTEGER);
    }

    Token *lexString()
    {
        string lexeme = "" ~ this.match('\"');
        while(!this.test('\"')){
            if(this.test('\\')){
                lexeme ~= "" ~ this.advance ~ this.advance;
            }else{
                lexeme ~= "" ~ this.advance;
            }
        }
        lexeme ~= "" ~ this.match('\"');
        return this.makeToken(lexeme, Token.Type.STRING);
    }

    Token *lexChar()
    {
        string lexeme = "" ~ this.match('\'');
        if(this.test('\\')){
            lexeme ~= "" ~ this.advance ~ this.advance;
        }else{
            lexeme ~= "" ~ this.advance;
        }
        lexeme ~= this.match('\'');
        return this.makeToken(lexeme, Token.Type.CHAR);
    }

    /* UTILITY FUNCTIONS */

    Token *lexMultiple(Args...)(char defla, TokenType deftype,
                                char altla, TokenType alttype, Args args)
    {
        if(this.test(altla, 1)){
            return this.makeAndAdvance(""~defla~altla, alttype, 2);
        }
        static if(args.length % 2 && args.length > 0){
            return this.lexMultiple(defla, deftype, args);
        }else{
            return this.makeAndAdvance(""~defla, deftype);
        }
    }

    Token *handleKeyword(Token *tok)
    {
        if(tok.type == Token.Type.ID){
            switch(tok.lexeme){
            case "let": tok.type = Token.Type.LET; break;
            case "proc": tok.type = Token.Type.PROC; break;
            case "func": tok.type = Token.Type.FUNC; break;
            case "if": tok.type = Token.Type.IF; break;
            case "else": tok.type = Token.Type.ELSE; break;
            case "extern": tok.type = Token.Type.EXTERN; break;
            case "static": tok.type = Token.Type.STATIC; break;
            case "import": tok.type = Token.Type.IMPORT; break;
            case "const": tok.type = Token.Type.CONST; break;
            case "struct": tok.type = Token.Type.STRUCT; break;
            case "then": tok.type = Token.Type.THEN; break;
            default: break;
            }
        }
        return tok;
    }

    Token *makeAndAdvance(string lexeme, Token.Type type, size_t n=1)
    {
        auto ret = this.makeToken(lexeme, type);
        while(n--){
            this.advance;
        }
        return ret;
    }

    Token *makeToken(string lexeme, Token.Type type)
    {
        return new Token(lexeme, type, this.buff.getLocation);
    }


    char la(size_t n=0)
    {
        while(this.la_buff.length <= n){
            this.la_buff ~= this.buff.next;
        }
        return this.la_buff[n];
    }

    char advance()
    {
        if(!this.la_buff.length){
            throw new LexerException("Reached end of lookahead buffer");
        }
        char ret = this.la_buff[0];
        this.la_buff = this.la_buff[1..$];
        if(this.buff.hasNext){
            this.la_buff ~= this.buff.next;
        }
        return ret;
    }

    char match(char c)
    {
        if(!this.test(c)){
        }
        return this.advance;
    }

    bool test(char c, size_t n=0)
    {
        return this.la(n) == c;
    }

    bool test(bool delegate(dchar) t)
    {
        return t(this.la);
    }

    bool test(string s)
    {
        foreach(x; s){
            if(!this.test(x)){
                return false;
            }
        }
        return true;
    }

    void ignore(char c)
    {
        while(this.buff.hasNext && this.test(c)){
            this.advance;
        }
    }

    void ignore(bool delegate(dchar) foo)
    {
        while(this.buff.hasNext && foo(this.la)){
            this.advance;
        }
    }
private:
    char[] la_buff;     // move to std.container.array!char
    LexerInputBuffer buff;
};

unittest
{
    import parse.StringInputBuffer;
    import parse.Token;

    enum tests = [
        ("this_is_an_id _this_too", [Token.Type.ID, Token.Type.ID]),
        ("this_is_an_id _this_too", [Token.Type.ID, Token.Type.ID])
    ];
    
    foreach(x; tests){
        auto lexer = new Lexer(new StringInputBuffer(x));
        Token[] tokens;
        while(lexer.hasNext){
            tokens ~= lexer.next;
        }
    }
}
