module gen.OutputBuilder;

import std.string;
import std.range;
import std.algorithm;
import std.stdio;

import util;

public interface OutputStream {
    OutputStream write(in string s);
};

public class FileStream : OutputStream {
    this(File *f)
    {
        this.file = f;
    }

    this(ref File f)
    {
        this(&f);
    }

    this(in string filename)
    {
        this(new File(filename, "w"));
    }

    override OutputStream write(in string s)
    {
        this.file.write(s);
        return this;
    }
private:
    File *file;
};

public class StringStream : OutputStream {
    this(ref string s)
    {
        this.str = &s; 
    }

    override OutputStream write(in string s)
    {
        *this.str ~= s;
        return this;
    }
private:
    string *str;
};

public struct OutputBuilder {
    static enum TAB_WIDTH = 4u;
    OutputStream *output;
    uint tablevel = 0;
    bool usetabs = true;
    bool statem = false;


    this(ref OutputStream s)
    {
        this.output = &s;
    }

    auto printf(Args...)(in string fmt, Args args)
    {
        const auto tabs = this.usetabs ? 
                             " ".repeat
                             .take(OutputBuilder.TAB_WIDTH * this.tablevel)
                             .foldOr!"a ~= b"("") :
                             "";

        this.output.write(tabs ~ fmt.format(args));
        return this;
    }

    auto printfln(Args...)(in string fmt, Args args)
    {
        return this.printf(fmt ~ (this.statem ? ";" : "") ~ '\n', args);
    }

    auto statement(Func)(Func f)
    {
        f();
        this.untabbed({
            this.printfln(";");
        });
        return this;
    }

    auto tabbed(Func)(Func body_fun)
    {
        auto def = this.usetabs;
        this.usetabs = true;
        body_fun();
        this.usetabs = def;
        return this;
    }

    auto untabbed(Func)(Func body_fun)
    {
        auto def = this.usetabs;
        this.usetabs = false;
        body_fun();
        this.usetabs = def;
        return this;
    }

    auto statements(Func)(Func body_fun)
    {
        auto def = this.statem;
        this.statem = true;
        body_fun();
        this.statem = def;
        return this;
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
