module parse.generator.TokenRange;

import parse.lex.Token;

/* TODO move parser stuff */

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
private:
    Token *delegate() next;
};
