module parse.Lexer;
import parse.Token;
import parse.LexerInputBuffer;

import std.container;
import std.stdio;
import std.exception;
import std.ascii;
import std.string;

class LexerException : Exception { mixin basicExceptionCtors; };

bool isIdBody(dchar c) pure
{
    return isAlpha(c) || isDigit(c) || c == '_';
}

template tryMultiLook(char la, char next, TokenType def, TokenType mat)
{
}

final class Lexer {
    import std.functional;
public:
    this(LexerInputBuffer input)
    {
        this.buff = input;
        if(!this.buff.hasNext()){
            throw new LexerException("Lexer was provided an empty buffer");
        }
        this.la_buff ~= this.buff.next();
    }

    Token *next()
    {
        if(!this.buff.hasNext()){
            throw new LexerException("Reached end of input buffer");
        }

        // Ignore preceding whitespace
        this.ignore((&isWhite).toDelegate);

        // Ignore comments
        if(this.test('/') && this.test('/', 1)){
            this.ignore(delegate(dchar c){
                return c != '\n';
            });
            this.advance();
        }

        switch(this.la){
        /* Punctuation */
        case '{': return this.makeAndAdvance("{", Token.Type.LBRACE);
        case '}': return this.makeAndAdvance("}", Token.Type.RBRACE);
        case '(': return this.makeAndAdvance("(", Token.Type.LPAREN);
        case ')': return this.makeAndAdvance(")", Token.Type.RPAREN);
        case ';': return this.makeAndAdvance(";", Token.Type.SEMI);
        case ':': return this.makeAndAdvance(":", Token.Type.COLON);
        /* Operators */
        case '*': return this.makeAndAdvance("*", Token.Type.STAR);
        case '%': return this.makeAndAdvance("%", Token.Type.REM);
        case '=': return this.tryMultiLook('=', '=', Token.Type.EQ, Token.Type.EQEQ);
        case '<': return this.tryMultiLook('<', '=', Token.Type.LT, Token.Type.LTEQ);
        case '>': return this.tryMultiLook('>', '=', Token.Type.GT, Token.Type.GTEQ);
        case '-': return this.tryMultiLook('-', '>', Token.Type.MINUS, Token.Type.RARROW);
        /* Etc. Rules */
        case '"': return this.lexString;
        case '_': return this.lexId;
        default:
            if(this.test(toDelegate(&isAlpha))){
                return this.lexId;
            }else if(this.test(toDelegate(&isDigit))){
                return this.lexNumber;
            }
            throw new LexerException("Couldn't match on character '%c'"
                                        .format(this.la()));
        }
    }

    bool hasNext() pure
    {
        return this.buff.hasNext;
    }
private:
    /* LEXER RULES */

    Token *lexId()
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

    /* TODO add raw character literals as well as escaped characters */
    Token *lexString()
    {
        string lexeme;
        lexeme ~= this.match('"');
        while(!this.test('"')){
            lexeme ~= this.advance;
        }
        lexeme ~= this.match('"');
        return this.makeToken(lexeme, Token.Type.STRING);
    }

    /* UTILITY FUNCTIONS */

    Token *tryMultiLook(char la, char next, Token.Type def, Token.Type mat)
    {
        if(this.test(next, 1)){
            return this.makeAndAdvance(""~la~next, mat);
        }
        return this.makeAndAdvance(""~la, def);
    }

    Token *handleKeyword(Token *tok) pure
    {
        if(tok.type == Token.Type.ID){
            switch(tok.lexeme){
            case "let": tok.type = Token.Type.LET; break;
            case "proc": tok.type = Token.Type.PROC; break;
            case "func": tok.type = Token.Type.FUNC; break;
            case "if": tok.type = Token.Type.IF; break;
            case "else": tok.type = Token.Type.ELSE; break;
            default: break;
            }
        }
        return tok;
    }

    Token *makeAndAdvance(string lexeme, Token.Type type, size_t n=1)
    {
        auto ret = this.makeToken(lexeme, type);
        while(n--){
            this.advance();
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
            this.la_buff ~= this.buff.next();
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
        if(this.buff.hasNext()){
             this.la_buff ~= this.buff.next();
        }
        return ret;
    }

    char match(char c)
    {
        if(!this.test(c)){
        }
        return this.advance();
    }

    bool test(char c, size_t n=0)
    {
        return this.la(n) == c;
    }

    bool test(bool delegate(dchar) t)
    {
        return t(this.la());
    }

    void ignore(char t)
    {
        while(this.buff.hasNext() && this.test(t)){
            this.advance();
        }
    }

    void ignore(bool delegate(dchar) t)
    {
        while(this.buff.hasNext() && t(this.la())){
            this.advance();
        }
    }
private:
    char[] la_buff;     // move to std.container.array!char
    LexerInputBuffer buff;
};
