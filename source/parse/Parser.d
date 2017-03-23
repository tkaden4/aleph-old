module parse.Parser;

import parse.Lexer;
import parse.Token;
import parse.symbol.Type;
import parse.nodes.ASTNode;
import parse.nodes.ProcDeclNode;
import parse.nodes.IntegerNode;
import parse.nodes.ExpressionNode;
import parse.nodes.BlockNode;

import std.exception;
import std.stdio;
import std.string;
import std.typecons;

alias ParseResult(T) = Nullable!T;
auto presult(T)(T t)
{
    return ParseResult!T(t);
}

T getOrThrow(T)(Nullable!T n, const Exception ex)
{
    if(n.isNull){
        throw ex;
    }
    return n.get;
}

class ParserException : Exception { mixin basicExceptionCtors; };

final class Parser {
public:
    this(Lexer lexer)
    {
        this.lexer = lexer;
    }

    invariant
    {
        assert(this.lexer !is null, "Parser was provided a null lexer");
    }

    /* PARSER RULES */

    auto literalExpression()
    {
        import std.conv;
        if(this.test(Token.Type.INTEGER)){
            auto num = this.match(Token.Type.INTEGER).lexeme.to!long;
            return presult!ExpressionNode(new IntegerNode(num));
        }else{
            throw new ParserException("No Literal Available");
        }
    }

    auto blockExpression()
    {
        ExpressionNode[] res = [];
        this.match(Token.Type.LBRACE);
        while(!this.test(Token.Type.RBRACE)){
            res ~= this.expression;
        }
        this.match(Token.type.RBRACE);
        return presult!ExpressionNode(new BlockNode(res));
    }

    ParseResult!ExpressionNode primaryExpression()
    {
        switch(this.la.type){
        /* { expression* } */
        case Token.Type.LBRACE: return this.blockExpression;
        /* ( expression ) */
        case Token.Type.LPAREN:
            this.match(Token.Type.LPAREN);
            auto ret = this.expression;
            this.match(Token.Type.RPAREN);
            return ret;
        /* Literals */
        case Token.Type.INTEGER:
        case Token.Type.STRING:
        case Token.Type.FLOAT:
        case Token.Type.CHAR:
            return this.literalExpression;
        /* TODO add function calls, Etc. */
        default: return ParseResult!ExpressionNode.init;
        }
    }

    auto expression()
    {
        return presult(this.primaryExpression.get);
    }

    auto parseType()
    {
        this.match(Token.Type.ID);
        return nullable!Type(Primitives.Int);
    }

    auto parameters()
    {
        Parameter[] params;
        while(this.test(Token.Type.ID)){
            params ~= Parameter(this.match(Token.Type.ID, Token.Type.COLON)[0].lexeme,
                                this.parseType.getOrThrow(
                                    new ParserException("Expected a type")));
            if(this.test(Token.Type.COMMA)){
                this.advance;
            }
        }
        return nullable(params);
    }

    ProcDeclNode procDecl()
    {
        auto toks = this.match(Token.Type.PROC, Token.Type.ID, Token.Type.LPAREN);
        auto params = this.parameters;
        this.match(Token.Type.RPAREN, Token.Type.RARROW);
        // TODO add type inferencing
        auto ret_type = this.parseType.getOrThrow(
                            new ParserException("No return type"));
        this.match(Token.Type.EQ);
        auto expression = this.expression.getOrThrow(
                            new ParserException("Unable to parse expression"));
        return new ProcDeclNode(toks[1].lexeme, ret_type, params, expression);
    }
private:
    /* UTILITY FUNCTIONS */

    auto la(size_t n=0)
    {
        while(this.la_buff.length <= n){
            this.la_buff ~= this.lexer.next;
        }
        return this.la_buff[n];
    }

    auto advance()
    {
        if(this.la_buff.empty){
            throw new ParserException("Reached end of lookahead buffer");
        }
        auto ret = this.la_buff[0];
        this.la_buff = this.la_buff[1..$];
        if(this.lexer.hasNext){
             this.la_buff ~= this.lexer.next;
        }
        return ret;
    }

    auto match(U...)(Token.Type t, Token.Type t2, U args)
    {
        auto ret = [this.match(t), this.match(t2)];
        static if(args.length > 0){
            return ret ~ this.match(args);
        }else{
            return ret;
        }
    }

    auto match(Token.Type c)
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
