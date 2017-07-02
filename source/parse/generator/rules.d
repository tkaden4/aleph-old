module parse.generator.rules;

import parse.lex.Token;
import util;

import syntax;
import parse.generator;

/* TODO fix recursive rules */
auto primaryRule(ref TokenRange range)
{
     range.parseOr!(
        parseSequence!(
            parseToken!(Token.Type.LPAREN),
            //StoreAs!(expression, "parenExp"),
            parseToken!(Token.Type.RPAREN)),
        StoreAs!(parseToken!(Token.Type.INTEGER), "intVal"),
        StoreAs!(parseToken!(Token.Type.STRING), "strVal"),
        StoreAs!(parseToken!(Token.Type.FLOAT), "floatVal"));
     return "";
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
            parseOptional!(parseToken!(Token.Type.ENDSTMT)),
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
        "importDecl");

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
            "procedure",
            true);

alias declaration =
    RuleImpl!(
        //parseOr!(StoreAs!(procedure, "proc"), StoreAs!(importDecl, "importD")),
        StoreAs!(procedure, "procedure"),
        "declaration",
        true);

alias program =
    RuleImpl!(
        StoreAs!(parseAnyAmount!(declaration), "declarations"),
        "program",
        true);

import parse.lex.Lexer;
public auto parseRule(alias Rule)(Lexer lexer)
{
    auto range = TokenRange(&lexer.next);
    return Rule(range);
}
