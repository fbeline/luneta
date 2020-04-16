import std.stdio;
import std.string;
import std.conv;
import std.typecons;
import std.algorithm;
import std.array;
import fuzzyd.core;
import deimos.ncurses.curses;
import luneta.printers;
import luneta.keyboard;
import luneta.window;

string[] parseStdin()
{
    string l;
    string[] lines;
    while ((l = stdin.readln()) !is null)
        lines ~= strip(l);
    return lines;
}

void maybesearch(fuzzyFn fzy, ref KeyProcessor kp)
{
    if (kp.dosearch)
    {
        kp.allMatches = fzy(kp.pattern);
        kp.matches = kp.pattern.empty ? kp.allMatches
            : kp.allMatches.filter!(m => m.score > 0).array();
        kp.selected = getWindowSize() - 3;
    }
}

void delegate() loop(fuzzyFn fzy, ref string result)
{
    const printFn[] printers = [
        &printMatches, &printSelection, &printTotalMatches, &printCursor
    ];
    return delegate void() {
        auto kp = KeyProcessor();
        do
        {
            kp.getKey();
            clear();
            if (kp.terminate)
            {
                result = kp.getSelected;
                break;
            }

            maybesearch(fzy, kp);
            foreach (fn; printers)
                fn(kp);
            refresh();
        }
        while (kp.key.type != KeyType.UNKOWN);
    };
}

int main()
{
    auto fzy = fuzzy(parseStdin());
    string result;
    init(loop(fzy, result));
    writeln(result);
    return 0;
}
