module parse.generator.rules;

import parse.lex.Token;
import util;

import parse.generator;

/* TODO fix recursive rules */
import syntax;
auto primaryRule(ref TokenRange range)
{
    return range.parseOr!(
        parseSequence!(
            parseToken!(Token.Type.LPAREN),
            //StoreAs!(RuleImpl!(primaryRule, "primary"), "parenExp"),
            parseToken!(Token.Type.RPAREN)),
        StoreAs!(parseToken!(Token.Type.INTEGER), "intVal"),
        StoreAs!(parseToken!(Token.Type.STRING), "strVal"),
        StoreAs!(parseToken!(Token.Type.FLOAT), "floatVal"));
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
            "procedure");

alias declaration =
    RuleImpl!(
        parseOr!(procedure, importDecl),
        "declaration");

alias program =
    RuleImpl!(
        parseAnyAmount!(declaration),
        "program");

import parse.lex.Lexer;
import std.stdio;

public auto parseRule(alias Rule)(Lexer lexer)
{
    auto range = TokenRange(&lexer.next);
    return Rule(range);
}
