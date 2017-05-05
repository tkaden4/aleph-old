module parse.StringView;

public import parse.SourceLocation;
import std.string;
import std.conv;

public class StringView {
public:
    this(in SourceLocation location, const(char) *str, size_t len)
    {
        this.chars = str;
        this.loc = location;
        this.len = len;
    }

    ref const(string) asString()
    {
        if(!this.lazy_str){
            const(char)[] arr;
            for(size_t i = 0; i < this.len; ++i){
                arr ~= this.chars[i];
            }
            arr ~= '\0';
            this.lazy_str = arr.ptr.fromStringz.to!string;
        }
        return this.lazy_str;
    }
private:
    const(SourceLocation) loc;
    const(char)* chars;
    size_t len;
    string lazy_str;
};
