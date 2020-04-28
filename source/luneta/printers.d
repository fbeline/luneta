module luneta.printers;

import std.conv;
import std.algorithm;
import std.uni;
import std.string : count;
import luneta.window;
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
        int i;
        foreach (c; m.value.byCodePoint)
        {
            const isMatch = indexes.removeKey(i) > 0;
            const isSelected = line is kp.selected;
            if (isMatch && isSelected)
            {
                withColor(Colors.SELECTED_MATCH, delegate void() {
                    mvaddch(line, i + 2, c);
                });
            }
            else if (isSelected)
            {
                withColor(Colors.SELECTED, delegate void() {
                    mvaddch(line, i + 2, c);
                });
            }
            else if (isMatch)
            {
                withColor(Colors.MATCH, delegate void() {
                    mvaddch(line, i + 2, c);
                });
            }
            else
            {
                mvaddch(line, i + 2, c);
            }
            i++;
        }
        if (m.value.count > getWindowSize.width - 1)
        {
            mvprintw(line, getWindowSize.width - 2, "...");
        }
    }

    for (int i; i < min(getWindowSize.height, kp.matches.length); i++)
    {
        immutable int lineNumber = maxLines - i - 1;
        printLine(lineNumber, kp.matches[i]);
    }
}

void printSelection(KeyProcessor kp)
{
    attron(A_BOLD);
    withColor(Colors.ARROW, delegate void() {
        if (kp.matches.length > 0)
            mvprintw(kp.selected, 0, "> ");
    });
    attroff(A_BOLD);
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
