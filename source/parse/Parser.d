module parse.Parser;

public import parse.ParserException;

import parse.lex.Lexer;
import syntax.tree;
import semantics.type.FunctionType;

import std.stdio;
import std.string;
import std.typecons;

import util;

public final class Parser {
private:
    alias ParseResult(T) = Nullable!T;
    auto presult(T)(T t)
    {
        return ParseResult!T(t);
    }
public:

    static Parser fromFile(string name)
    {
        import parse.lex.FileInputBuffer;
        return new Parser(new Lexer(new FileInputBuffer(name)));
    }

    static Parser fromFile(ref File file)
    {
        import parse.lex.FileInputBuffer;
        return new Parser(new Lexer(new FileInputBuffer(file)));
    }

    this(Lexer lexer)
    {
        this.lexer = lexer;
    }

    invariant
    {
        assert(this.lexer !is null, "Parser was provided a null lexer");
    }

    /* PARSER RULES */

    auto program()
    {
        StatementNode[] res;
        while(this.lexer.hasNext){
            res ~= this.declaration.getOrThrow(
                       new ParserException("Unable to parse declaration") 
                   );
        }
        return new ProgramNode(res);
    }

    auto literalExpression()
    {
        import std.conv;
        switch(this.la.type){
        case Token.Type.INTEGER:
            auto num = this.match(Token.Type.INTEGER).lexeme.to!int;
            return presult!ExpressionNode(new IntegerNode(num));
        case Token.Type.CHAR:
            auto tok = this.match(Token.Type.CHAR);
            auto ch = tok.lexeme[1..$-1].to!char;
            return presult!ExpressionNode(new CharNode(ch));
        default:
            "Literal not implemented".writeln;
            return ParseResult!ExpressionNode.init;
        }
    }

    ParseResult!ExpressionNode primaryExpression()
    {
        switch(this.la.type){
        /* ID */
        case Token.Type.ID: 
            auto id = this.match(Token.Type.ID);
            return presult!ExpressionNode(new IdentifierNode(id.lexeme, null));
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

    ExpressionNode[] paramExpressions()
    {
        ExpressionNode[] ret;
        while(!this.test(Token.Type.RPAREN)){
            ret ~= this.expression.getOrThrow(
                        new ParserException("No expression in parameters"));
            if(this.test(Token.Type.COMMA)){
                this.advance;
            }
        }
        return ret;
    }

    auto postfixExpression()
    {
        auto postOp(ExpressionNode node)
        {
            switch(this.la.type){
            case Token.Type.LPAREN:
                this.match(Token.Type.LPAREN);
                auto args = this.paramExpressions;
                this.match(Token.Type.RPAREN);
                return presult!ExpressionNode(new CallNode(node, args));
            default:
                return ParseResult!ExpressionNode.init;
            }
        }
        
        auto exp = this.primaryExpression;
        auto ret = postOp(exp.getOrThrow(new ParserException("postfix requires an expression")));
        while(!ret.isNull){
            exp = ret;
            ret = postOp(exp.getOrThrow(new ParserException("no expression in postfix")));
        }
        return exp;
    }

    auto expression()
    {
        return this.postfixExpression;
    }

    auto statement()
    {
        switch(this.la.type){
        case Token.Type.LET:
        case Token.Type.PROC:
            return cast(ParseResult!ExpressionNode)this.declaration;
        default: return this.expression;
        }
    }

    auto blockExpression()
    {
        ExpressionNode[] res;
        this.match(Token.Type.LBRACE);
        while(!this.test(Token.Type.RBRACE)){
            auto exp = this.statement;
            res ~= exp.getOrThrow(new ParserException("Invalid block body"));
        }
        this.match(Token.type.RBRACE);
        return presult!ExpressionNode(new BlockNode(res));
    }

    /* TODO add more complex types */
    Type parseType()
    {
        switch(this.la.type){
        case Token.Type.STAR:
            this.advance;
            return new PointerType(this.parseType);
        /* Primitive type */
        case Token.Type.ID:
            return this.match(Token.Type.ID).lexeme.toPrimitive;
        /* Function types */
        /* TODO add multiple parameter types */
        case Token.Type.LPAREN:
            this.match(Token.Type.LPAREN);
            auto param = this.parseType;
            this.match(Token.Type.RPAREN);
            this.match(Token.Type.RARROW);
            auto ret = this.parseType;
            return new FunctionType(ret, [param]);
        default:
            throw new ParserException("Couldn't parse type");
        }
    }

    auto parameters()
    {
        Parameter[] params;
        while(this.test(Token.Type.ID)){
            params ~= Parameter(this.match(Token.Type.ID,
                                           Token.Type.COLON)[0].lexeme,
                                           this.parseType);
            if(this.test(Token.Type.COMMA)){
                this.advance;
            }
        }
        return nullable(params);
    }

    auto procDecl()
    {
        auto toks = this.match(Token.Type.PROC, Token.Type.ID);

        auto params = this.test(Token.Type.LPAREN).use!((x){
            this.match(Token.Type.LPAREN);
            auto params = this.parameters;
            this.match(Token.Type.RPAREN);
            return params.get;
        }).or(null);

        auto ret_type = this.test(Token.Type.RARROW).use!((x){
            this.match(Token.Type.RARROW);
            return this.parseType;
        }).or(null);

        this.match(Token.Type.EQ);

        auto exp = this.expression.getOrThrow(new ParserException("Unable to parse expression"));
        return presult(new ProcDeclNode(toks[1].lexeme, ret_type, params, exp));
    }

    auto varDecl()
    {
        auto toks = this.match(Token.Type.LET, Token.Type.ID);

        auto type = this.test(Token.Type.COLON).use!((x){
            this.match(Token.Type.COLON);
            return this.parseType;
        }).or(null);

        this.test(Token.Type.EQ)
            .use_err!(x => this.advance)(new ParserException("Variables must be initialized"));

        auto exp = this.expression.getOrThrow(
                                    new ParserException("Variables must be initialized"));
        return presult(new VarDeclNode(toks[1].lexeme, type, exp));
    }

    auto declaration()
    {
        switch(this.la.type){
        case Token.Type.PROC: return cast(ParseResult!StatementNode)this.procDecl;
        case Token.Type.LET: return cast(ParseResult!StatementNode)this.varDecl;
        default: throw new ParserException("Couldn't parse declaration");
        }
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
        return this.la_buff.use_err!((x){
            auto ret = this.la_buff[0];
            this.la_buff = this.la_buff[1..$];
            this.la_buff ~= this.lexer.next;
            return ret;
        })(new ParserException("Reached end of lookahead buffer"));
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
        return this.test(c).use_err!(
            x => this.advance
        )(new ParserException("Could not match %s with %s".format(this.la.type, c)));
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
