module parse.Parser;

public import parse.ParserException;

import parse.lex.Lexer;
import syntax.tree;
import semantics;
import util;

import std.stdio;
import std.string;
import std.typecons;
import std.range;

public final class Parser {
    import parse.lex.FileInputBuffer;
public:
    static auto fromFile(in string name)
    {
        return new Parser(new Lexer(new FileInputBuffer(name)));
    }

    static auto fromFile(ref File file)
    {
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
            Declaration[] res;
            while(this.lexer.hasNext){
                res ~= this.topLevel;
            }
            return tuple(new Program(res), this.resultTable);
        }catch(ParserException e){
            throw new AlephException("parser error [%s, %s, %s] : %s"
                                .format(this.la.location.filename, this.la.location.line_no, this.la.location.col_no, e.msg));
        }
    }

    /* any node at the top level of the file */
    Declaration topLevel()
    {
        switch(this.la.type){
        case Token.Type.EXTERN: return this.externRule;
        case Token.Type.PROC:   return this.procDecl;
        case Token.Type.STRUCT: return this.structDecl;
        case Token.Type.IMPORT: this.importDecl; return this.topLevel;
        default:
            throw new ParserException("did not expect %s at top level".format(*this.la));
        }
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

    Declaration externRule()
    {
        this.advance;
        switch(this.la.type){
        case Token.Type.PROC:   return this.externProc;
        case Token.Type.IMPORT: return this.externImport;
        default:
            throw new ParserException("did not expect %s after \"extern\"".format(this.la.lexeme));
        }
    }

    Expression literalExpression()
    {
        import std.conv;
        switch(this.la.type){
        case Token.Type.INTEGER:
            return this.match(Token.Type.INTEGER)
                       .use!(x => new IntPrimitive(x.lexeme.to!int));
        case Token.Type.CHAR:
            return this.match(Token.Type.CHAR)
                       .use!(x => new CharPrimitive(x.lexeme[1..$-1].to!char));
        case Token.Type.STRING:
            return new StringPrimitive(this.advance.lexeme[1..$-1]);
        default:
            throw new ParserException("invalid literal \"%s\"", this.la.lexeme);
        }
    }

    auto typedParameterList(Token.Type end)
    {
        auto params = this.parseSepListOf(
            Token.Type.COMMA,
            { auto name = this.match(Token.Type.ID);
              this.match(Token.Type.COLON);
              auto type = this.parseType;
              return Parameter(name.lexeme, type); },
            { return this.test(end); });
        return params;
    }

    /* EXPRESSIONS */

    Expression structInit()
    {
        auto name = this.match(Token.Type.ID).lexeme;
        this.match(Token.Type.LBRACE);
        ParamInit[] inits;
        while(!this.test(Token.Type.RBRACE)){
            auto param = this.match(Token.Type.ID, Token.Type.EQ)[0].lexeme;
            auto value = this.expression;
            this.optional(Token.Type.COMMA);
            inits ~= ParamInit(param, value);
        }
        this.match(Token.Type.RBRACE);
        return new StructInit(name, inits, new UnknownType);
    }

    // TODO add struct init
    Expression primaryExpression()
    {
        switch(this.la.type){
        /* lambda */
        case Token.Type.BSLASH:
            this.advance;
            auto params = this.typedParameterList(Token.Type.RARROW);
            this.match(Token.Type.RARROW);
            return new Lambda(params, this.expression);
        /* ID */
        case Token.Type.ID: 
            if(this.test(Token.Type.LBRACE, 1)){
                return this.structInit;
            }
            auto id = this.match(Token.Type.ID);
            auto node = new Identifier(id.lexeme, new UnknownType);
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
                               .or(new EmptyExpression);
            return new IfExpression(ifexp, thenexp, elseexp, new UnknownType);
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
        Expression postOp(Expression node, bool optional=true)
        {
            switch(this.la.type){
            case Token.Type.COLON:
                this.advance;
                return new Cast(node, this.parseType);
            case Token.Type.LPAREN:
                this.match(Token.Type.LPAREN);
                auto args = this.paramExpressions;
                this.match(Token.Type.RPAREN);
                return new Call(node, args);
            default:
                optional.err(new ParserException("non-optional post-exp"));
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

    Expression multiplicativeExpression()
    {
        auto exp = this.postfixExpression;
        switch(this.la.type){
        case Token.Type.PLUS:
        case Token.Type.MINUS:
            auto op = this.advance.lexeme;
            return new BinaryExpression(exp, this.multiplicativeExpression, op, new UnknownType);
        default: break;
        }
        return exp;
    }


    Expression additiveExpression()
    {
        auto exp = this.multiplicativeExpression;
        switch(this.la.type){
        case Token.Type.PLUS:
        case Token.Type.MINUS:
            auto op = this.advance.lexeme;
            return new BinaryExpression(exp, this.additiveExpression, op, new UnknownType);
        default: break;
        }
        return exp;
    }


    Expression equalityExpression()
    {
        auto exp = this.multiplicativeExpression;
        switch(this.la.type){
        case Token.Type.LTEQ:
        case Token.Type.GTEQ:
        case Token.Type.NEQ:
        case Token.Type.EQEQ:
            auto op = this.advance.lexeme;
            return new BinaryExpression(exp, this.equalityExpression, op, new UnknownType);
        default: break;
        }
        return exp;
    }


    alias expression = this.equalityExpression;

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
        return new Block(this.parseListOf(Token.Type.LBRACE,
                                             &this.statement,
                                             Token.Type.RBRACE));
    }

    alias parseType = qualifiedType;

    /* parse an unqualified type */
    Type unqualifiedType()
    {
        switch(this.la.type){
            case Token.Type.STAR:
                return this.advance.use!(() => new PointerType(this.parseType));
            /* Primitive type or single-parameter function */
            case Token.Type.ID:
                return this.advance.lexeme.toPrimitive;
            /* Function types */
            case Token.Type.LPAREN:
                this.match(Token.Type.LPAREN);
                auto params = this.parseSepListOf(Token.Type.COMMA,
                                                  &this.parseType,
                                                  () => this.test(Token.Type.RPAREN));
                this.match(Token.Type.RPAREN, Token.Type.RARROW);
                return new FunctionType(this.parseType, params);
        default:
            throw new ParserException("%s is not the start of an unqualified type".format(this.la.lexeme));
        }
    }

    /* Parse a possibly qualified type */
    Type qualifiedType()
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
            return this.advance
                       .use!({ return new QualifiedType(TypeQualifier.Const, this.unqualifiedType ); });
        default:
            return this.unqualifiedType;
        }
    }

    /* DECLARATIONS */

    auto procDecl()
    {

        auto toks = this.match(Token.Type.PROC, Token.Type.ID);
        auto params = this.test(Token.Type.LPAREN).use!((x){
            this.match(Token.Type.LPAREN);
            auto params = typedParameterList(Token.type.RPAREN);
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
                   return new ProcDecl(name, ret_type, params, x); });
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
        return new VarDecl(toks[1].lexeme, type, exp);
    }

    Declaration declaration()
    {
        bool external = false;
        switch(this.la.type){
        case Token.Type.EXTERN:
            return this.externDecl;
        case Token.Type.PROC: 
            return this.procDecl;
        case Token.Type.IMPORT:
        case Token.Type.STRUCT: return this.structDecl;
        case Token.Type.LET: return this.varDecl;
        default: throw new ParserException("Couldn't parse declaration");
        }
    }

    auto structDecl()
    {
        this.match(Token.Type.STRUCT);
        auto name = this.match(Token.Type.ID).lexeme;
        auto fields = this.parseListOf(Token.Type.LBRACE,
                                       { auto name = this.match(Token.Type.ID).lexeme;
                                         this.match(Token.Type.COLON);
                                         auto type = this.parseType;
                                         this.optional(Token.Type.ENDSTMT);
                                         return StructDecl.Field(name, type); },
                                       Token.Type.RBRACE);
        return new StructDecl(name, fields).then!(x => x.writeln);
    }

    /* EXTERNAL RULES */

    Declaration externDecl()
    {
        this.match(Token.Type.EXTERN);
        switch(this.la.type){
        case Token.Type.PROC: return this.externProc;
        case Token.Type.IMPORT: return this.externImport;
        default: throw new AlephException("invalid external declaration");
        }
    }

    auto externImport()
    {
        auto toks = this.match(Token.Type.IMPORT, Token.Type.STRING);
        return new ExternImport(toks[1].lexeme[1..$-1]);
    }

    auto externProc()
    {
        auto name = this.match(Token.Type.PROC, Token.Type.ID).back.lexeme;
        this.match(Token.Type.LPAREN);
        bool vararg = false;
        auto params = this.parseSepListOf(Token.Type.COMMA,
                                          &this.parseType,
                                          () => this.test(Token.Type.VARARG)
                                                    .if_then!({ this.advance; vararg = true; })
                                                    .or(vararg || this.test(Token.Type.RPAREN)));
        this.match(Token.type.RPAREN, Token.Type.RARROW);
        return new ExternProc(name, this.parseType, params, vararg);
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

    bool test(F)(F t)
        if(is(isCallable!t) &&
           is(ReturnType!t == bool) &&
           is(Parameters!t[0] == Token.Type))
    {
        return t(this.la.type);
    }

    void ignore(Token.Type t)
    {
        while(this.lexer.hasNext && this.test(t)){
            this.advance;
        }
    }

    void ignore(F)(F t)
        if(is(isCallable!t) &&
           is(ReturnType!t == bool) &&
           is(Parameters!t[0] == Token.Type))
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
