module parse.Lexer;
import parse.Token;

import std.container;
import std.stdio;
import std.exception;
import std.ascii;
import std.string;

interface LexerInputBuffer {
    /* gets the current location */
    SourceLocation getLocation() pure;
    /* read next character */
    char next();
    bool hasNext() pure;
};

class LexerException : Exception { mixin basicExceptionCtors; };

bool isIdBody(dchar c) pure
{
    return isAlpha(c) || isDigit(c) || c == '_';
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

        this.ignore(delegate(char c){
            return c == ' ' || c == '\t' || c == '\n';
        });

        Token *ret = null;
        switch(this.la()){
        case '{':
            ret = this.makeAndAdvance("{", Token.Type.LBRACE);
            break;
        case '}':
            ret = this.makeAndAdvance("}", Token.Type.RBRACE);
            break;
        case '(':
            ret = this.makeAndAdvance("(", Token.Type.LPAREN);
            break;
        case ')':
            ret = this.makeAndAdvance(")", Token.Type.RPAREN);
            break;
        case ';':
            ret = this.makeAndAdvance(";", Token.Type.SEMI);
            break;
        case '=':
            ret = this.makeAndAdvance("=", Token.Type.EQ);
            break;
        case '_':
            ret = this.lexId();
            break;
        case '-':   /* either minus or right arrow */
            if(this.test('>', 1)){
                ret = this.makeAndAdvance("->", Token.Type.RARROW, 2);
            }else{
                ret = this.makeAndAdvance("-", Token.Type.MINUS);
            }
            break;
        default:
            if(this.test(toDelegate(&isAlpha))){
                ret = this.lexId();
            }else if(this.test(toDelegate(&isDigit))){
                ret = this.lexNumber();
            }else{
                throw new LexerException(
                        "Couldn't match on character '%c'".format(this.la())
                    );
            }
        }

        // Check for keywords
        if(ret.type == Token.Type.ID){
            switch(ret.lexeme){
            case "let":
                ret.type = Token.Type.LET;
                break;
            case "proc":
                ret.type = Token.Type.PROC;
                break;
            default:
                break;
            }
        }

        return ret;
    }


    bool hasNext() pure
    {
        return this.buff.hasNext();
    }
private:
    /* LEXER RULES */

    Token *lexId()
    {
        string lexeme;
        while(this.test(toDelegate(&isIdBody))){
            lexeme ~= this.advance();
        }
        return this.makeToken(lexeme, Token.Type.ID);
    }

    /* TODO handle floating-point numbers */
    Token *lexNumber()
    {
        string lexeme;
        while(this.test(toDelegate(&isDigit))){
            lexeme ~= this.advance();
        }
        return this.makeToken(lexeme, Token.Type.INTEGER);
    }

    /* UTILITY FUNCTIONS */

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

    void ignore(bool delegate(char) t)
    {
        while(this.buff.hasNext() && t(this.la())){
            this.advance();
        }
    }
private:
    char[] la_buff;     // move to std.container.array!char
    LexerInputBuffer buff;
};
