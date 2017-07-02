module parse.generator.TokenRange;

import parse.lex.Token;
import std.traits;
import std.range;

/* TODO implement */

public struct TokenRange {
    this(Token *delegate() next)
    {
        this.next = next;
    }

    /* match next token */
    auto match(Token.Type type)
    {
        auto tok = this.la;
        if(tok.type != type){
            throw new Exception("Couldn't match");
        }
        return this.advance;
    }

    /* match types.length tokens */
    auto match(Token.Type[] types...)
    {
        Token*[] result;
        foreach(i, x; types){
            result ~= this.match(x);
        }
        return result;
    }

    /* look at next token available */
    auto la(size_t n=0)
    {
        if(this.buffer.length == n){
            for(size_t i = 0; i <= n; ++i){
                this.cache(this.next());
            }
        }
        return this.buffer[n];
    }

    /* advance past token */
    auto advance()
    {
        auto ret = this.la;
        this.uncache(1);
        this.cache(this.next());
        return ret;
    }

    /* remove tokens from lookahead buffer */
    auto uncache(size_t n=1)
    {
        if(n > this.buffer.length){
            throw new Exception("Cannot uncache nothing");
        }
        auto ret = this.buffer[0..n];
        this.buffer = this.buffer[n..$];
        return ret;
    }

    /* add a token to lookahead buffer */
    auto cache(Token *tok)
    {
        assert(tok, "cached token is null");
        this.buffer ~= tok;
    }

    /* XXX just for now */
    auto attempt(alias f)()
        if(isCallable!f)
    {
        /* dont discard tokens */
        /* allow rewinding */
        /*
        try {

        } catch(Exception e) {
            throw e;
        }
        */
        return f(this);
    }

    /* for InputRange */
    auto empty()
    {
        if(this.buffer.empty) this.cache(this.next());
        return this.buffer.back.type == Token.Type.EOS;
    }
    alias front = this.la;
    alias popFront = this.advance;

    @property auto dup()
    {
        auto ret = TokenRange(this.next);
        ret.buffer = this.buffer.dup;
        return ret;
    }

private:
    Token*[] buffer;
    // advance to next token
    Token *delegate() next;
};
