module luneta.printers;

import std.conv;
import std.algorithm;
import std.string : toStringz, strip;
import deimos.ncurses.curses;
import luneta.keyboard;
import fuzzyd.core;

const MAX_PRINT = 20;
alias printFn = void function(KeyProcessor);

void printMatches(KeyProcessor kp)
{

    void printLine(int line, FuzzyResult m)
    {
        auto indexes = m.matches.dup;
        for (int i; i < m.value.length; i++)
        {
            if (indexes.removeKey( i) > 0)
            {
                attron( A_BOLD);
                mvprintw( line, i + 2, toStringz( m.value[i].to!string));
                attroff( A_BOLD);
            }
            else
            {
                mvprintw( line, i + 2, toStringz( m.value[i].to!string));
            }
        }
    }

    for (int i; i < min(MAX_PRINT, kp.matches.length); i++)
    {
        immutable int lineNumber = MAX_PRINT - i - 1;
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
    attron(A_REVERSE);
    immutable stopLine = max(0, MAX_PRINT - kp.matches.length);
    for (int i = MAX_PRINT - 1; i >= stopLine; i--)
        mvprintw(i, 0, toStringz(" "));
    if (kp.matches.length > 0)
        mvprintw(kp.selected, 0, toStringz("> "));
    attroff(A_REVERSE);
}

void printTotalMatches(KeyProcessor kp)
{
    auto str = (to!string(kp.matches.length) ~ "/" ~ to!string(kp.allMatches.length)).toStringz;

    attron(A_BOLD);
    mvprintw(MAX_PRINT, 1, str);
    attroff(A_BOLD);
}

void printCursor(KeyProcessor kp)
{
    mvprintw(MAX_PRINT + 1, 0, toStringz("> " ~ kp.pattern));
}
