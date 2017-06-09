module parse.generator.RuleImpl;

import std.traits;
import std.meta;
import std.typecons;

import parse.generator.TokenRange;

public template RuleImpl(alias Fun, string ruleName, bool storeRule=false)
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

template RulePair(alias Rule)
{
    alias RulePair = AliasSeq!(ReturnType!Rule, Rule.name);
};
