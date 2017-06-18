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

    static auto from(Token[] t)
    {
        import std.range;
        import std.functional;
        //alias fun = partial!();
        return TokenRange();
    }

    /* match next token */
    auto match(Token.Type type)
    {
        auto tok = this.la;
        if(tok.type != type){
            throw new Exception("Couldn't match");
        }
        this.advance;
        return tok;
    }

    /* match types.length tokens */
    auto match(Token.Type[] types...)
    {
        Token*[] result;
        result.reserve(types.length);
        foreach(i, x; types){
            result[i] = this.match(x);
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
    auto advance(size_t n=1)
    {
        while(n--){
            this.uncache(1);
            this.cache(this.next());
        }
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
        this.buffer ~= tok;
    }

    /* TODO fix with LL(*) parsing algorithms */
    auto attempt(Func)(scope Func f)
        if(isCallable!Func)
    {
        return null;
    }

    /* for InputRange */
    @property
    auto empty()
    {
        return this.buffer.empty;
    }
    alias front = this.la;
    alias popFront = this.advance;

private:
    Token*[] buffer;
    // advance to next token
    Token *delegate() next;
};
