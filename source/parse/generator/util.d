module parse.generator.util;

import std.meta;
import std.traits;
import std.typecons;

import parse.generator;
import parse.lex.Token;

/* create a rule that parses with
 * operator precedence given a base
 * rule and a list of token types
 * that represent operators */
template parsePrecedence(string genName,
                         alias BaseRule,
                         Token.Type[][] rules)
{
    auto parsePrecedenceImpl(ref TokenRange range)
    {
        return "";
    }
    
    alias parsePrecedence =
        RuleImpl!(
            parsePrecedenceImpl,
            genName);
}; 

alias parsed =
    parsePrecedence!(
        "binaryExpression",
        primaryExpression,
        [
            [ Token.Type.PLUS, Token.Type.MINUS ],
            [ Token.Type.STAR, Token.Type.DIV ],
        ]);

/* rule | rule2 */
auto parseOr(Rules...)(ref TokenRange range)
{
    alias OrResult = Tuple!(staticMap!(RulePair, Rules));
    auto result = OrResult();
    foreach(i, x; Rules){
        static assert(isRule!x, "invalid rule");
        static if(x.store){
            //enum setVal = "result." ~ x.name ~ " = cast(" ~ ReturnType!x.stringof ~ ")x(range);"; 
            //mixin(setVal);
        }
    }
    return result;
}

/* rule (n or more times) */
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
        foreach(i, x; Rules){
            static assert(isRule!x, "invalid rule");
        }
        return Tuple!(staticMap!(ReturnType, Rules))();
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

