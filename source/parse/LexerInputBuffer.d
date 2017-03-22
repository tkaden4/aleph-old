module parse.LexerInputBuffer;

import parse.Token;

interface LexerInputBuffer {
    /* gets the current location */
    SourceLocation getLocation() pure;
    /* read next character */
    char next();
    bool hasNext() pure;
};
