module luneta.printers;

import std.conv;
import std.algorithm;
import deimos.ncurses.curses;
import luneta.window : mvprintw, getWindowSize;
import luneta.keyboard;
import fuzzyd.core;

alias printFn = void function(KeyProcessor);

private:

void printMatches(KeyProcessor kp)
{
    const maxLines = getWindowSize.height - 2;
    void printLine(int line, FuzzyResult m)
    {
        auto indexes = m.matches.dup;
        for (int i; i < m.value.length; i++)
        {
            if (indexes.removeKey(i) > 0)
            {
                attron(A_BOLD);
                mvprintw(line, i + 2, m.value[i].to!string);
                attroff(A_BOLD);
            }
            else
            {
                mvprintw(line, i + 2, m.value[i].to!string);
            }
        }
        if (m.value.length > getWindowSize.width)
        {
            mvprintw(line, getWindowSize.width-2, "...");
        }
    }

    for (int i; i < min(getWindowSize.height, kp.matches.length); i++)
    {
        immutable int lineNumber = maxLines - i - 1;
        if (lineNumber is kp.selected)
        {
            attron(A_REVERSE);
            printLine(lineNumber, kp.matches[i]);
            attroff(A_REVERSE);
        }
        else
        {
            printLine(lineNumber, kp.matches[i]);
        }
    }
}

void printSelection(KeyProcessor kp)
{
    immutable maxLines = getWindowSize.height - 2;

    attron(A_REVERSE);
    immutable stopLine = max(0, maxLines - kp.matches.length);
    if (kp.matches.length > 0)
        mvprintw(kp.selected, 0, "> ");
    attroff(A_REVERSE);
}

void printTotalMatches(KeyProcessor kp)
{
    auto str = kp.matches.length.to!string ~ "/" ~ kp.all.length.to!string;

    attron(A_BOLD);
    mvprintw(getWindowSize.height - 2, 1, str);
    attroff(A_BOLD);
}

void printCursor(KeyProcessor kp)
{
    mvprintw(getWindowSize.height - 1, 0, "> " ~ kp.pattern);
    move(getWindowSize.height - 1, kp.cursorx + 2);
}

public:
/// print all necessary screen elements
void print(KeyProcessor kp)
{
    const printFn[] printers = [
        &printMatches, &printSelection, &printTotalMatches, &printCursor
    ];

    clear;

    foreach (fn; printers)
        fn(kp);

    refresh;
}
