module gen.OutputBuilder;

import std.string;
import std.range;
import std.algorithm;
import std.stdio;


interface OutputStream {
    void write(string s);
};

class FileStream : OutputStream {
    this(File *f)
    {
        this.file = f;
    }

    this(ref File f)
    {
        this(&f);
    }

    override void write(string s)
    {
        this.file.write(s);
    }
private:
    File *file;
};

class StringStream : OutputStream {
    this(ref string s)
    {
        this.str = &s; 
    }

    override void write(string s)
    {
        *this.str ~= s;
    }
private:
    string *str;
};

struct OutputBuilder {
    static enum TAB_WIDTH = 4u;
    OutputStream output;
    uint tablevel = 0;
    bool usetabs = true;
    bool statem = false;


    this(OutputStream s)
    {
        this.output = s;
    }

    auto printf(Args...)(string fmt, Args args)
    {
        const auto tabs = this.usetabs ? 
                             " ".repeat
                             .take(OutputBuilder.TAB_WIDTH * this.tablevel)
                             .foldOr!"a ~= b"("") :
                             "";

        this.output.write(tabs ~ fmt.format(args));
        return this;
    }

    auto printfln(Args...)(string fmt, Args args)
    {
        return this.printf(fmt ~ '\n', args);
    }

    auto tabbed(Func)(Func body_fun)
    {
        auto def = this.usetabs;
        this.usetabs = true;
        body_fun();
        this.usetabs = def;
    }

    auto untabbed(Func)(Func fun)
    {
        auto def = this.usetabs;
        this.usetabs = false;
        fun();
        this.usetabs = def;
    }

    auto statements(Func)(Func body_fun)
    {
        auto def = this.statem;
        this.statem = true;
        body_fun();
        this.statem = def;
    }

    auto block(Func)(Func body_fun)
    {
        this.tabbed({
            this.printfln("{");
            ++this.tablevel;
            body_fun();
            --this.tablevel;
            this.printfln("}");
        });
        return this;
    }
};

auto foldOr(alias func, T, F)(T inRange, F defaultVal)
{
    if(inRange.empty){
        return defaultVal;
    }
    return inRange.fold!func;
}

