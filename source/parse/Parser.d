module parse.Parser;

import parse.Lexer;
import parse.Token;
import parse.nodes.ASTNode;

import std.exception;
import std.stdio;
import std.string;

class ParserException : Exception { mixin basicExceptionCtors; };

final class Parser {
public:
    this(Lexer lexer)
    {
        this.lexer = lexer;
    }

    invariant
    {
        assert(this.lexer);
    }

    /* PARSER RULES */

    ASTNode procDecl()
    {
        auto toks = this.match(Token.Type.PROC, Token.Type.ID, Token.Type.LPAREN);
        "Found function with id \"%s\"".format(toks[1].lexeme).writeln;
        return null;
    }
private:
    /* UTILITY FUNCTIONS */

    const(Token) *la(size_t n=0)
    {
        while(this.la_buff.length <= n){
            this.la_buff ~= this.lexer.next;
        }
        return this.la_buff[n];
    }

    const(Token) *advance()
    {
        if(this.la_buff.empty){
            throw new ParserException("Reached end of lookahead buffer");
        }
        const(Token) *ret = this.la_buff[0];
        this.la_buff = this.la_buff[1..$];
        if(this.lexer.hasNext){
             this.la_buff ~= this.lexer.next;
        }
        return ret;
    }

    const(Token)*[] match(U...)(Token.Type t, Token.Type t2, U args)
    {
        const(Token)*[] ret = [this.match(t), this.match(t2)];
        static if(args.length > 0){
            return ret ~ this.match(args);
        }else{
            return ret;
        }
    }

    const(Token) *match(Token.Type c)
    {
        import std.string;
        if(!this.test(c)){
            throw new ParserException("Could not match %s with %s"
                                        .format(this.la.type, c));
        }
        return this.advance;
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
