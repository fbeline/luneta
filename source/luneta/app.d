module luneta.app;

import std.stdio;
import std.string;
import std.getopt;
import fuzzyd.core;
import luneta.printers;
import luneta.keyboard;
import luneta.window;
import luneta.opts;
import std.algorithm;
import std.container.binaryheap;
import std.range;

private:

const string VERSION = "v0.7.2";

struct Result
{
    string[] value;
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

Result filterMode(fuzzyFn fzy, long size, string pattern)
{
    auto fr = new FuzzyResult[size];
    const total = fzy(pattern, fr);
    return Result(
        heapify!"a.score < b.score"(fr)
            .take(total)
            .map!(x => x.value)
            .array);
}

void delegate() loop(fuzzyFn fzy, ulong dbsize, ref Result result)
{
    return delegate void() {
        auto kp = new KeyProcessor(fzy, dbsize);
        print(kp);
        do
        {
            kp.getKey;
            if (kp.terminate is Terminate.OK)
            {
                result.value = kp.result;
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
    bool _version;
    auto helpInformation = getopt(args, std.getopt.config.passThrough,
            "version|v", "version", &_version,
            "query|q", "default query to be used upon startup", &luneta.opts.query,
            "filter|f", "do not start interactive finder, e.g -f=\"pattern\"", &luneta.opts.filter,
            "height", "set the maximum window height (number of lines), e.g --height 25", &luneta.opts.height,
            "color", "color support, e.g --color=FALSE", &luneta.opts.colorSupport);

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

    auto db = parseStdin();
    auto fzy = fuzzy(db);
    Result result = Result();

    if (luneta.opts.filter.empty)
        init(loop(fzy, db.length, result));
    else
        result = filterMode(fzy, db.length, luneta.opts.filter);

    foreach (l; result.value)
    {
        writeln(l);
    }

    return result.status;
}
