module parse.lex.LexerInputBuffer;

import parse.lex.Token;

public interface LexerInputBuffer {
    /* gets the current location */
    SourceLocation getLocation() pure;
    /* read next character */
    char next();
    bool hasNext() pure;
};
