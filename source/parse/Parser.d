module parse.Parser;

import symbol.Type;

import parse.lex.Lexer;
import parse.nodes.ASTNode;
import parse.nodes.VarDeclNode;
import parse.nodes.ProcDeclNode;
import parse.nodes.IntegerNode;
import parse.nodes.CharNode;
import parse.nodes.ExpressionNode;
import parse.nodes.BlockNode;
import parse.nodes.StatementNode;
import parse.nodes.IdentifierNode;
import symbol.SymbolTable;

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

struct ParserResult {
    ASTNode root;       /* root of the tree */
    ProcDeclNode[] untyped_proc;    /* list of procedures with no types */
    VarDeclNode[] untyped_var;      /* list of variables with no types */
};

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

    /* CHAR, STRING, INTEGER, FLOAT */
    auto literalExpression()
    {
        import std.conv;
        switch(this.la.type){
        case Token.Type.INTEGER:
            auto num = this.match(Token.Type.INTEGER).lexeme.to!long;
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

    ParseResult!ExpressionNode statement()
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
        ExpressionNode[] res = [];
        this.match(Token.Type.LBRACE);
        while(!this.test(Token.Type.RBRACE)){
            auto exp = this.statement;
            res ~= exp.getOrThrow(new ParserException("Invalid block body"));
        }
        this.match(Token.type.RBRACE);
        return presult!ExpressionNode(new BlockNode(res));
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

    auto expression()
    {
        return this.primaryExpression;
    }

    auto parseType()
    {
        auto tok = this.match(Token.Type.ID);
        auto type = tok.lexeme.toPrimitive;
        return type;
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
        auto toks = this.match(Token.Type.PROC, Token.Type.ID, Token.Type.LPAREN);
        auto params = this.parameters;
        this.match(Token.Type.RPAREN);

        Type ret_type = null;
        if(this.test(Token.Type.RARROW)){
            this.match(Token.Type.RARROW);
            ret_type = this.parseType;
        }

        this.match(Token.Type.EQ);
        ExpressionNode exp = this.expression.getOrThrow(new ParserException("Unable to parse expression"));
        return presult(new ProcDeclNode(toks[1].lexeme, ret_type, params, exp));
    }

    auto varDecl()
    {
        auto toks = this.match(Token.Type.LET, Token.Type.ID);
        Type type = null;
        if(this.test(Token.Type.COLON)){
            this.match(Token.Type.COLON);
            type = this.parseType;
        }
        if(!this.test(Token.Type.EQ)){
            throw new ParserException("Variables must be initialized");
        }
        this.match(Token.Type.EQ);
        ExpressionNode exp = this.expression.getOrThrow(
                                    new ParserException("Variables must be initialized"));
        return presult(new VarDeclNode(toks[1].lexeme, type, exp));
    }

    ParseResult!StatementNode declaration()
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
