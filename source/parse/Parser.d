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
            return new ProgramNode(res);
        }catch(ParserException e){
            throw new Exception("parser error [%s, %s, %s] : %s"
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
            //throw new ParserException("Imports?");
            return this.importDecl;
        default:
            break;
        }
        throw new ParserException("did not expect %s at top level".format(*this.la));
    }

    ImportNode importDecl()
    {
        this.match(Token.Type.IMPORT);
        string path = "";
        path ~= this.match(Token.Type.ID).lexeme;
        while(this.test(Token.Type.DOT)){
            this.match(Token.Type.DOT);
            path ~= ("." ~ this.match(Token.Type.ID).lexeme);
        }
        return new ImportNode(path);
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
            auto num = this.match(Token.Type.INTEGER).lexeme.to!int;
            return new IntegerNode(num);
        case Token.Type.CHAR:
            auto tok = this.match(Token.Type.CHAR);
            auto ch = tok.lexeme[1..$-1].to!char;
            return new CharNode(ch);
        case Token.Type.STRING:
            return new StringNode(this.advance.lexeme);
        default:
            throw new ParserException("invalid literal \"%s\"", this.la.lexeme);
        }
    }

    ExpressionNode primaryExpression()
    {
        switch(this.la.type){
        /* ID */
        case Token.Type.ID: 
            auto id = this.match(Token.Type.ID);
            return new IdentifierNode(id.lexeme, null);
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
            ExpressionNode elseexp = null;
            if(this.test(Token.Type.ELSE)){
                this.match(Token.Type.ELSE);
                elseexp = this.expression;
            }
            return new IfExpressionNode(ifexp, thenexp, elseexp, null);
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

    ExpressionNode[] paramExpressions()
    {
        ExpressionNode[] ret;
        while(!this.test(Token.Type.RPAREN)){
            ret ~= this.expression;
            if(this.test(Token.Type.COMMA)){
                this.advance;
            }
        }
        return ret;
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
            return new BinOpNode(exp, this.additiveExpression, "+", null);
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
            return new BinOpNode(exp, this.equalityExpression, "==", null);
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
        ExpressionNode[] res;
        this.match(Token.Type.LBRACE);
        while(!this.test(Token.Type.RBRACE)){
            auto exp = this.statement;
            res ~= exp;
        }
        this.match(Token.type.RBRACE);
        return new BlockNode(res);
    }

    /* TODO add more complex types */
    Type parseType()
    {
        switch(this.la.type){
        case Token.Type.CONST:
            this.advance;
            return new QualifiedType(TypeQualifier.Const, this.parseType);
        case Token.Type.STAR:
            this.advance;
            return new PointerType(this.parseType);
        /* Primitive type or single-parameter function */
        case Token.Type.ID:
            /* TODO fix const functions */
            if(this.test(Token.Type.RARROW, 1)){
                return this.advance.lexeme.toPrimitive.use!((x){
                    this.match(Token.Type.RARROW);
                    return this.parseType.use!(k => new FunctionType(k, [x]));
                });
            }else{
                auto x = this.match(Token.Type.ID);
                return x.lexeme.toPrimitive;
            }
        /* Function types */
        /* TODO add multiple parameter types */
        case Token.Type.LPAREN:
            this.match(Token.Type.LPAREN);
            Type[] params;
            while(!this.test(Token.Type.RPAREN)){
                params ~= this.parseType;
            }
            this.match(Token.Type.RPAREN);
            this.match(Token.Type.RARROW);
            auto ret = this.parseType;
            return new FunctionType(ret, params);
        default:
            throw new ParserException("%s is not the start of a valid type".format(*this.la));
        }
    }

    auto parameters()
    {
        Parameter[] params;
        while(this.test(Token.Type.ID)){
            auto name = this.match(Token.Type.ID);
            this.match(Token.Type.COLON);
            auto type = this.parseType;
            params ~= Parameter(type, name.lexeme);
            if(this.test(Token.Type.COMMA)){
                this.advance;
            }
        }
        return params;
    }

    auto procDecl()
    {
        auto toks = this.match(Token.Type.PROC, Token.Type.ID);

        auto params = this.test(Token.Type.LPAREN).use!((x){
            this.match(Token.Type.LPAREN);
            auto params = this.parameters;
            this.match(Token.Type.RPAREN);
            return params;
        }).or(null);

        auto ret_type = this.test(Token.Type.RARROW).use!((x){
            this.match(Token.Type.RARROW);
            return this.parseType;
        }).or(null);

        ExpressionNode exp = null;
        this.match(Token.Type.EQ);
        exp = this.expression;

        return new ProcDeclNode(toks[1].lexeme, ret_type, params, exp);
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
        case Token.Type.STRUCT:
            return this.structDecl;
        case Token.Type.LET: return this.varDecl;
        default: throw new ParserException("Couldn't parse declaration");
        }
    }

    StatementNode structDecl()
    {
        throw new ParserException("structs are currently not supported");
            /*
        auto name = this.match(Token.Type.STRUCT, Token.Type.ID)[1];
        this.match(Token.Type.LBRACE);
        while(!this.test(Token.Type.RBRACE)){
            // Get a struct declarator "x: int"
        }
        // return new StructDeclNode(name, variables);
        */
        //return ParseResult!ASTNode.init;
    }

    auto externImport()
    {
        auto toks = this.match(Token.Type.IMPORT, Token.Type.STRING);
        return new ExternImportNode(toks[1].lexeme[1..$-1]);
    }

    auto externProc()
    {
        auto name = this.match(Token.Type.PROC, Token.Type.ID)[1].lexeme;
        Type[] params = [];
        bool vararg = false;
        if(this.test(Token.Type.LPAREN)){
            this.advance;
            while(!this.test(Token.Type.RPAREN)){
                if(this.test(Token.Type.VARARG)){
                    this.advance;
                    vararg = true;
                    break;
                }
                params ~= this.parseType;
                if(this.test(Token.Type.COMMA)){
                    this.advance;
                }
            }
            this.advance;
        }

        this.match(Token.Type.RARROW);
        auto ret = this.parseType;
        return new ExternProcNode(name, ret, params, vararg);
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
        return this.la_buff.err(new ParserException("Reached end of lookahead buffer")).use!((x){
            auto ret = this.la_buff[0];
            this.la_buff = this.la_buff[1..$];
            this.la_buff ~= this.lexer.next;
            return ret;
        });
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
};
