module parse.Parser;

public import parse.ParserException;

import parse.lex.Lexer;
import syntax.tree;
import semantics.type;
import semantics.symbol;

import std.stdio;
import std.string;
import std.typecons;

import AlephException;
import util;


public final class Parser {
public:
    static Parser fromFile(in string name)
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
        this.resultTable = new AlephTable("Global Table");
    }

    invariant
    {
        assert(this.lexer !is null, "Parser was provided a null lexer");
    }

    /* PARSER RULES */

    auto program()
    {
        try{
            StatementNode[] res;
            while(this.lexer.hasNext){
                res ~= this.topLevel;
            }
            return tuple(new ProgramNode(res), this.resultTable);
        }catch(ParserException e){
            throw new AlephException("parser error [%s, %s, %s] : %s"
                                .format(this.la.location.filename, this.la.location.line_no, this.la.location.col_no, e.msg));
        }
    }

    /* any node at the top level of the file */
    StatementNode topLevel()
    {
        switch(this.la.type){
        case Token.Type.EXTERN:
            return this.externRule;
        case Token.Type.PROC:
            return this.procDecl;
        case Token.Type.STRUCT:
            return this.structDecl;
        case Token.Type.IMPORT:
            this.importDecl;
            return this.topLevel;
        default:
            break;
        }
        throw new ParserException("did not expect %s at top level".format(*this.la));
    }

    void importDecl()
    {
        this.match(Token.Type.IMPORT);
        string path = "";
        path ~= this.match(Token.Type.ID).lexeme;
        while(this.test(Token.Type.DOT)){
            this.match(Token.Type.DOT);
            path ~= ("." ~ this.match(Token.Type.ID).lexeme);
        }
        path = path.replace(".", "/") ~ ".al";
        import library;
        this.resultTable.loadLibrary(path);
    }

    StatementNode externRule()
    {
        this.advance;
        switch(this.la.type){
        case Token.Type.PROC:
            return this.externProc;
        case Token.Type.IMPORT:
            return this.externImport;
        default:
            throw new ParserException("did not expect %s after \"extern\"".format(this.la.lexeme));
        }
    }

    ExpressionNode literalExpression()
    {
        import std.conv;
        switch(this.la.type){
        case Token.Type.INTEGER:
            return this.match(Token.Type.INTEGER)
                       .use!(x => new IntegerNode(x.lexeme.to!int));
        case Token.Type.CHAR:
            return this.match(Token.Type.CHAR)
                       .use!(x => new CharNode(x.lexeme[1..$-1].to!char));
        case Token.Type.STRING:
            return new StringNode(this.advance.lexeme[1..$-1]);
        default:
            throw new ParserException("invalid literal \"%s\"", this.la.lexeme);
        }
    }

    /* EXPRESSIONS */

    ExpressionNode primaryExpression()
    {
        switch(this.la.type){
        /* ID */
        case Token.Type.ID: 
            auto id = this.match(Token.Type.ID);
            auto node = new IdentifierNode(id.lexeme, new UnknownType);
            return node;
        /* { expression* } */
        case Token.Type.LBRACE: return this.blockExpression;
        /* ( expression ) */
        case Token.Type.LPAREN:
            this.match(Token.Type.LPAREN);
            auto ret = this.expression;
            this.match(Token.Type.RPAREN);
            return ret;
        /* if expression then expression else expression */
        case Token.Type.IF:
            this.match(Token.Type.IF);
            auto ifexp = this.expression;
            this.match(Token.Type.THEN);
            auto thenexp = this.expression;
            auto elseexp = this.test(Token.Type.ELSE)
                               .use!((x){ this.advance; return this.expression; })
                               .or(null);
            return new IfExpressionNode(ifexp, thenexp, elseexp, new UnknownType);
        /* Literals */
        case Token.Type.INTEGER:
        case Token.Type.STRING:
        case Token.Type.FLOAT:
        case Token.Type.CHAR:
            return this.literalExpression;
        /* TODO add function calls, Etc. */
        default: throw new ParserException("\"%s\" does not start a primary expression".format(this.la.lexeme));
        }
    }

    auto paramExpressions()
    {
        return this.parseSepListOf(Token.Type.COMMA,
                                   &this.expression,
                                   () => this.test(Token.Type.RPAREN));
    }

    auto postfixExpression()
    {
        auto postOp(ExpressionNode node, bool optional)
        {
            switch(this.la.type){
            case Token.Type.LPAREN:
                this.match(Token.Type.LPAREN);
                auto args = this.paramExpressions;
                this.match(Token.Type.RPAREN);
                return new CallNode(node, args);
            default:
                if(!optional){
                    throw new ParserException("expected postfix operator");
                }
                return null;
            }
        }
        
        auto exp = this.primaryExpression;
        auto ret = postOp(exp, true);
        while(ret){
            exp = ret;
            ret = postOp(exp, true);
        }
        return exp;
    }

    ExpressionNode additiveExpression()
    {
        auto exp = this.postfixExpression;
        switch(this.la.type){
        case Token.Type.PLUS:
            this.match(Token.Type.PLUS);
            return new BinOpNode(exp, this.additiveExpression, "+", new UnknownType);
        case Token.Type.MINUS:
            this.match(Token.Type.MINUS);
            return new BinOpNode(exp, this.additiveExpression, "-", new UnknownType);
        default: break;
        }
        return exp;
    }

    ExpressionNode equalityExpression()
    {
        auto exp = this.additiveExpression;
        switch(this.la.type){
        case Token.Type.EQEQ:
            this.match(Token.Type.EQEQ);
            auto x = new BinOpNode(exp, this.equalityExpression, "==", new UnknownType);
            return x;
        default: break;
        }
        return exp;
    }

    auto expression()
    {
        return this.equalityExpression;
    }

    auto statement()
    {
        switch(this.la.type){
        case Token.Type.EXTERN:
        case Token.Type.STATIC:
        case Token.Type.LET:
        case Token.Type.PROC:
            return this.declaration;
        default: return this.expression;
        }
    }

    auto blockExpression()
    {
        return new BlockNode(this.parseListOf(Token.Type.LBRACE,
                                             &this.statement,
                                             Token.Type.RBRACE));
    }

    /* Parse a type */
    auto parseType()
    {
        switch(this.la.type){
        case Token.Type.TYPEOF:
            this.match(Token.Type.TYPEOF, Token.Type.LPAREN);
            return this.expression
                       .then!({ this.match(Token.Type.RPAREN); })
                       .use!(x => x.resultType.match(
                                      (UnknownType type) => new TypeofType(x),
                                      emptyFunc!Type));
        case Token.Type.CONST:
            return this.advance.use!(_ => new QualifiedType(TypeQualifier.Const, this.parseType));
        case Token.Type.STAR:
            return this.advance.use!(_ => new PointerType(this.parseType));
        /* Primitive type or single-parameter function */
        case Token.Type.ID:
            /* TODO fix const functions */
            if(this.test(Token.Type.RARROW, 1)){
                return this.advance.lexeme.toPrimitive.use!((x){
                    this.match(Token.Type.RARROW);
                    return this.parseType.use!(k => new FunctionType(k, [x]));
                });
            }else{
                return this.advance.lexeme.toPrimitive;
            }
        /* Function types */
        case Token.Type.LPAREN:
            this.match(Token.Type.LPAREN);
            auto params = this.parseSepListOf(Token.Type.COMMA,
                                              &this.parseType,
                                              { return this.test(Token.Type.RPAREN); });
            this.match(Token.Type.RPAREN, Token.Type.RARROW);
            return new FunctionType(this.parseType, params);
        default:
            throw new ParserException("%s is not the start of a valid type".format(*this.la));
        }
    }

    /* DECLARATIONS */

    auto procDecl()
    {
        auto typedParameterList()
        {
            auto params = this.parseSepListOf(
                Token.Type.COMMA,
                {
                    auto name = this.match(Token.Type.ID);
                    this.match(Token.Type.COLON);
                    auto type = this.parseType;
                    return Parameter(type, name.lexeme);
                },
                { return this.test(Token.Type.RPAREN); });
            return params;
        }

        auto toks = this.match(Token.Type.PROC, Token.Type.ID);
        auto params = this.test(Token.Type.LPAREN).use!((x){
            this.match(Token.Type.LPAREN);
            auto params = typedParameterList();
            this.match(Token.Type.RPAREN);
            return params;
        });

        auto ret_type = this.test(Token.Type.RARROW).use!((x){
            this.match(Token.Type.RARROW);
            return this.parseType;
        }).or(null);

        if(this.test(Token.Type.EQ)){
            this.advance;
        }else if(!this.test(Token.Type.LBRACE)){
            throw new ParserException("non-block functions must have \'=\'");
        }

        return this.expression.use!((x){
                   ret_type = ret_type.or(new TypeofType(x));
                   auto name = toks[1].lexeme;
                   return new ProcDeclNode(name, ret_type, params, x); });
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

        auto exp = this.expression;
        type = type.or(new TypeofType(exp));
        return new VarDeclNode(toks[1].lexeme, type, exp);
    }

    StatementNode declaration()
    {
        bool external = false;
        switch(this.la.type){
        case Token.Type.EXTERN:
            this.advance;
            if(this.test(Token.Type.IMPORT)){
                return this.externImport;
           }else{
                external = true;
                goto case;
            }
        case Token.Type.PROC: 
            StatementNode ret = null;
            if(external){
                ret = this.externProc;
            }else{
                ret = this.procDecl;
            }
            return ret;
        case Token.Type.IMPORT:
        case Token.Type.STRUCT:
            return this.structDecl;
        case Token.Type.LET: return this.varDecl;
        default: throw new ParserException("Couldn't parse declaration");
        }
    }

    StatementNode structDecl()
    {
        throw new ParserException("structs are currently not supported");
    }

    /* EXTERNAL RULES */

    auto externImport()
    {
        auto toks = this.match(Token.Type.IMPORT, Token.Type.STRING);
        return new ExternImportNode(toks[1].lexeme[1..$-1]);
    }

    auto externProc()
    {
        auto name = this.match(Token.Type.PROC, Token.Type.ID)[1].lexeme;

        this.match(Token.Type.LPAREN);
        bool vararg = false;
        auto params = this.parseSepListOf(Token.Type.COMMA,
                                            &this.parseType,
                                            () => this.test(Token.Type.VARARG)
                                                       .if_then!({ this.advance; vararg = true; })
                                                       .or(vararg || this.test(Token.Type.RPAREN)));
        this.match(Token.type.RPAREN, Token.Type.RARROW);
        return new ExternProcNode(name, this.parseType, params, vararg);
    }
private:
    /* UTILITY FUNCTIONS */

    /* parse a list */
    auto parseListOf(F)(Token.Type start, F fun, Token.Type end)
    {
        import std.traits;
        ReturnType!(fun)[] ret;
        this.match(start);
        while(!this.test(end)){
            ret ~= fun();
        }
        this.match(end);
        return ret;
    }

    /* parse a separated list */
    auto parseSepListOf(T, F)(Token.Type delim, T next, F test)
    {
        import std.traits;
        ReturnType!(next)[] ret;
        while(!test()){
            ret ~= next();
            this.optional(delim);
        }
        return ret;
    }

    auto la(size_t n=0)
    {
        while(this.la_buff.length <= n){
            this.la_buff ~= this.lexer.next;
        }
        return this.la_buff[n];
    }

    auto advance()
    {
        return this.la_buff.err(new ParserException("Reached end of lookahead buffer")).use!((x){
            auto ret = this.la_buff[0];
            this.la_buff = this.la_buff[1..$];
            this.la_buff ~= this.lexer.next;
            return ret;
        });
    }

    auto optional(Token.Type type)
    {
        if(this.test(type)){
            return this.match(type);
        }
        return this.la;
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
        )(new ParserException("Could not match given token %s with expected token %s : %s".format(this.la.type, c, this.la.location)));
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
    Token*[] la_buff;
    Lexer lexer;
    AlephTable resultTable;
};
