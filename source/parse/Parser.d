module parse.Parser;

import parse.Lexer;
import parse.Token;
import parse.nodes.ASTNode;

import std.exception;

class ParserException : Exception { mixin basicExceptionCtors; };

final class Parser {
public:
    this(Lexer lexer)
    {
        this.lexer = lexer;
    }

    ASTNode procDecl()
    {
        this.match(Token.Type.PROC, Token.Type.ID, Token.Type.ID);
        return null;
    }
private:
    /* UTILITY FUNCTIONS */

    Token la(size_t n=0)
    {
        while(this.la_buff.length <= n){
            this.la_buff ~= this.lexer.next();
        }
        return *this.la_buff[n];
    }

    Token advance()
    {
        if(!this.la_buff.length){
            throw new ParserException("Reached end of lookahead buffer");
        }
        const(Token) *ret = this.la_buff[0];
        this.la_buff = this.la_buff[1..$];
        if(this.lexer.hasNext){
             this.la_buff ~= this.lexer.next();
        }
        return *ret;
    }

    Token[] match(U...)(Token.Type t, Token.Type t2, U args)
    {
        Token[] ret = [] ~ this.match(t) ~ this.match(t2);
        static if(U.length > 0){
            return ret ~ this.match(args);
        }else{
            return ret;
        }
    }

    Token match(Token.Type c)
    {
        import std.string;
        if(!this.test(c)){
            throw new ParserException("Could not match %s with %s"
                                        .format(this.la.type, c));
        }
        return this.advance();
    }

    bool test(Token.Type c, size_t n=0)
    {
        return this.la(n).type == c;
    }

    bool test(bool delegate(Token.Type) t)
    {
        return t(this.la.type);
    }

    void ignore(Token.Type t)
    {
        while(this.lexer.hasNext && this.test(t)){
            this.advance;
        }
    }

    void ignore(bool delegate(Token.Type) t)
    {
        while(this.lexer.hasNext && t(this.la.type)){
            this.advance;
        }
    }

private:
    const(Token)*[] la_buff;
    Lexer lexer;
};
