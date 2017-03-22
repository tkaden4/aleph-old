module parse.Parser;

import parse.Lexer;
import parse.Token;
import parse.nodes.ASTNode;

final class Parser {
public:
    this(Lexer lexer)
    {
        this.lexer = lexer;
    }

    auto procDecl()
    {
        return "";
    }
private:
    /* UTILITY FUNCTIONS */
private:
    const(Token)*[] la_buff;
    Lexer lexer;
};
