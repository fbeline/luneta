module luneta.app;

import std.stdio;
import std.string;
import std.getopt;
import fuzzyd.core;
import luneta.printers;
import luneta.keyboard;
import luneta.window;
import luneta.opts;

private:

const string VERSION = "v0.3.2";

struct Result
{
    string value;
    int status;
}

string[] parseStdin()
{
    string l;
    string[] lines;
    while ((l = stdin.readln()) !is null)
        lines ~= strip(l);
    return lines;
}

void delegate() loop(fuzzyFn fzy, ref Result result)
{
    return delegate void() {
        auto kp = new KeyProcessor(fzy);
        print(kp);
        do
        {
            kp.getKey;
            if (kp.terminate is Terminate.OK)
            {
                result.value = kp.getSelected;
                break;
            }
            else if (kp.terminate is Terminate.EXIT)
            {
                result.status = 1;
                break;
            }
            kp.search;
            print(kp);
        }
        while (kp.key.type != KeyType.UNKOWN);
    };
}

public:

int main(string[] args)
{

    int height;
    bool _version;
    auto helpInformation = getopt(args, std.getopt.config.passThrough, "height",
            "set the maximum window height (number of lines), e.g --height 25",
            &height, "version|v", "version", &_version);
    luneta.opts.initialize(height);

    if (helpInformation.helpWanted)
    {
        defaultGetoptPrinter("usage: luneta [options]", helpInformation.options);
        return 0;
    }
    if (_version)
    {
        writeln(VERSION);
        return 0;
    }

    auto fzy = fuzzy(parseStdin());
    Result result = Result();
    init(loop(fzy, result));
    writeln(result.value);
    return result.status;
}
