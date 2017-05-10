module parse.util.StringView;

public import parse.util.SourceLocation;
import std.string;
import std.conv;
import util.meta : Lazy;

public class StringView {
public:
    this(in SourceLocation location, const(char) *str, size_t len)
    {
        this.chars = str;
        this.loc = location;
        this.len = len;
    }

    private auto get(){
        const(char)[] arr;
        for(size_t i = 0; i < this.len; ++i){
            arr ~= this.chars[i];
        }
        arr ~= '\0';
        return arr.ptr.fromStringz.to!string;
    }

    mixin Lazy!("value", get);

public:
    const(SourceLocation) loc;
    const(char)* chars;
    size_t len;
};
