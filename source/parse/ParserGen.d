import std.exception;
import std.functional;
import std.meta;
import std.range;
import std.stdio;
import std.traits;
import std.typecons;
import std.string;
import std.variant;

import parse.lex.Token;
import util;

/* TODO finish all this parsing junk */

class ParseException : Exception {
    mixin basicExceptionCtors;
};

struct TokenRange {
    static auto from(Token[] t)
    {
        return TokenRange();
    }

    auto match(Token.Type type)
    {
        return Token();
    }
};

template RuleImpl(alias Fun, string ruleName, bool storeRule=false)
{
    static struct RuleImpl {
    static:
        enum name = ruleName;
        enum store = storeRule;

        auto opCall(ref TokenRange range)
        {
            return Fun(range);
        }
    };
};

/* copy a rule */
template Defer(alias Rule)
{
    alias Defer = RuleImpl!(Rule.opCall, Rule.name);
};

template isRule(alias Rule)
{
    enum isRule = isCallable!Rule; // && !is(ReturnType!Rule == void);
};

/* rule | rule2 */
auto parseOr(Rules...)(ref TokenRange range)
{
    pragma(msg, RuleResult!("OrResult", Rules));
    mixin(RuleResult!("OrResult", Rules));
    auto result = OrResult();
    foreach(i, x; Rules){
        static assert(isRule!x, "invalid rule");
        static if(x.store){
            mixin("result." ~ x.name ~ " = x(range);");
        }
    }
    return result;
}

/* rule+ (n or more times) */
auto parseAtLeastN(size_t n, alias Rule)(ref TokenRange range)
    if(isRule!Rule)
{
    ReturnType!Rule[] result;
    Rule(range);
    /*
    for(size_t i = 0; ; ++i){
        try {
            range.saveState({
                result ~= Rule(range);
            });
        } catch(ParseException e) {
            range.revert;
            if(i <= n){
                import std.string;
                throw new ParseException("couldn't parse %lu of rule".format(n));
            }
        }
    }
    */
    return result;
}

auto ruleProperty(alias Rule)()
    if(isRule!Rule)
{
    alias retType = ReturnType!Rule;
    return retType.stringof ~ " " ~ Rule.name;
}

/* rule+ */
auto parseOneOrMore(alias Rule)(ref TokenRange range)
    if(isRule!Rule)
{
    return range.parseAtLeastN!(1, Rule);
}

/* rule* */
template parseAnyAmount(alias Rule)
{
    alias parseAnyAmount = 
        RuleImpl!(
            range => range.parseAtLeastN!(0, Rule),
            Rule.name ~ "s",
            true);
};

/* rule rule2 ... ruleN */
template parseSequence(Rules...)
{

    auto parseSequenceImpl(ref TokenRange range)
    {
        pragma(msg, RuleResult!("SequenceResult", Rules));
        foreach(i, x; Rules){
            static assert(isRule!x, "invalid rule");
        }
        return Token();
    }

    alias parseSequence = 
        RuleImpl!(
            parseSequenceImpl,
            "sequential");
};

auto collectInto(alias Rule, alias How)(ref TokenRange range)
    if(isRule!Rule)
{
    return How(Rule(range));
}

template parseToken(Token.Type type)
{
    alias parseToken =
        RuleImpl!(
            range => range.match(type),
            "token");
};

/* rule? */
template parseOptional(alias Rule)
{
    alias parseOptional = 
        RuleImpl!(
            Rule,
            "parseOptional" ~ Rule.name);
};

template StoreAs(alias Rule, string name) 
{
    alias StoreAs = RuleImpl!(Rule.opCall, name, true);
};

/* TODO fix recursive rules */
auto primaryRule(ref TokenRange range)
{
    return range.parseOr!(
        parseSequence!(
            parseToken!(Token.Type.LPAREN),
            //StoreAs!(RuleImpl!(primaryRule, "primary"), "parenExp"),
            parseToken!(Token.Type.RPAREN)),
        StoreAs!(parseToken!(Token.Type.INTEGER), "intVal"),
        StoreAs!(parseToken!(Token.Type.STRING), "strVal"),
        StoreAs!(parseToken!(Token.Type.FLOAT), "floatVal"));
}

alias primaryExpression = 
    RuleImpl!(
        primaryRule,
        "primary",
        true);


alias multiplicativeExpression =
    RuleImpl!(
        parseSequence!(
            primaryExpression,
            parseAnyAmount!(
                parseSequence!(
                    parseToken!(Token.Type.PLUS),
                    primaryExpression))),
        "multiplicative");

alias additiveExpression =
    RuleImpl!(
        parseSequence!(
            multiplicativeExpression,
            parseAnyAmount!(
                parseSequence!(
                    parseToken!(Token.Type.PLUS),
                    multiplicativeExpression))),
        "additive");

alias expression = 
    RuleImpl!(
        additiveExpression,
        "expression",
        true);

alias block =
    RuleImpl!(
        parseSequence!(parseToken!(Token.Type.LBRACE),
            parseAnyAmount!(expression),
            parseToken!(Token.Type.RBRACE)),
        "block");

alias type = 
    RuleImpl!(
        parseToken!(Token.Type.ID),
        "type");

alias variable =
    RuleImpl!(
        parseSequence!(
            parseToken!(Token.Type.LET),
            parseToken!(Token.Type.ID),
            parseOptional!type,
            parseToken!(Token.Type.EQ),
            expression),
        "variable");

alias importDecl =
    RuleImpl!(
        parseSequence!(
            parseToken!(Token.Type.IMPORT),
            parseToken!(Token.Type.ID)),
        "import");

alias procedure =
    RuleImpl!(
        parseSequence!(
            parseToken!(Token.Type.PROC),
            parseToken!(Token.Type.ID),
            parseToken!(Token.Type.LPAREN),
            parseToken!(Token.Type.RPAREN),
            parseOptional!(
                parseSequence!(
                    parseToken!(Token.Type.RARROW),
                    type)),
            parseToken!(Token.Type.EQ),
            expression),
            "procedure");

alias declaration =
    RuleImpl!(
        parseOr!(procedure, importDecl),
        "declaration");

alias program =
    RuleImpl!(
        parseAnyAmount!(declaration),
        "program");


template RuleResult(string name, Rules...)
{
    template Members(Rules...)
    {
        static if(Rules.length == 0){
            enum Members = "";
        }else{
            alias curRule = Rules[0];
            static if(curRule.store){
                enum curProperty = ruleProperty!curRule;
                enum Members = "\t" ~ curProperty ~ ";\n" ~ Members!(Rules[1..$]);
            }else{
                enum Members = Members!(Rules[1..$]);
            }
        }
    };

    enum RuleResult = 
        "struct " ~ name ~ " {\n"
            ~ Members!Rules ~
        "}";
}

auto thingy()
{
    auto range = TokenRange.from([Token()]);
    auto x = range.program();
}
