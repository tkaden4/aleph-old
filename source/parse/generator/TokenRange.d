module parse.generator.TokenRange;

import parse.lex.Token;
import std.traits;

/* TODO implement */

public struct TokenRange {
    this(Token *delegate() next)
    {
        this.next = next;
    }

    static auto from(Token[] t)
    {
        return TokenRange();
    }

    auto match(Token.Type type)
    {
        return this.next();
    }

    auto attempt(Func)(Func f)
        if(isCallable!Func)
    {
        return null;
    }
private:
    // advance to next token
    Token *delegate() next;
};
