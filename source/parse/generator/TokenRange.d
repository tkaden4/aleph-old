module parse.generator.TokenRange;

import parse.lex.Token;

public struct TokenRange {
    static auto from(Token[] t)
    {
        return TokenRange();
    }

    auto match(Token.Type type)
    {
        return Token();
    }
private:
};
