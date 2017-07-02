module parse.generator.RuleImpl;

import std.traits;
import std.meta;
import std.typecons;

import parse.generator.TokenRange;

public template RuleImpl(alias Fun, string ruleName, bool storeRule=false)
{
    struct RuleImpl {
        enum name = ruleName;
        enum store = storeRule;

        pragma(inline);
        static auto opCall(ref TokenRange range)
        {
            return Fun(range);
        }
    };
};

template isRule(alias Rule)
{
    enum isRule = isCallable!Rule; // && !is(ReturnType!Rule == void);
};

template RulePair(alias Rule)
{
    static if(Rule.store){
        alias RulePair = AliasSeq!(ReturnType!Rule, Rule.name);
    }else{
        alias RulePair = AliasSeq!();
    }
};
