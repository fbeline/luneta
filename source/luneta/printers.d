module luneta.printers;

import std.conv;
import std.typecons;
import std.range;
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
    const maxLines = printArea.height;
    const maxCols = printArea.width;

    void print(Tuple!(bool, Colors)[] printOptions, int row, int col, dchar c)
    {
        foreach (p; printOptions)
        {
            if (p[0])
            {
                withColor(p[1], delegate void() { mvaddch(row, col + 2, c); });
                break;
            }
        }
    }

    void printLine(int line, FuzzyResult m)
    {
        int i;
        foreach (c; m.value.byCodePoint)
        {
            if (i > maxCols)
                break;

            bool isMatch = m.matches.canFind(i);
            bool isSelected = line is kp.selected;
            bool isSelectedMatch = (isMatch && isSelected) || kp.isIdxSelected(maxLines - line - 1);
            Tuple!(bool, Colors)[4] printOptions = [
                tuple(isSelectedMatch, Colors.SELECTED_MATCH),
                tuple(isSelected, Colors.SELECTED),
                tuple(isMatch, Colors.MATCH),
                tuple(true, Colors.DEFAULT)
            ];

            print(printOptions, line, i, c);

            i++;
        }
        if (m.value.walkLength > printArea.width - 1)
        {
            mvprintw(line, maxCols, "...");
        }
    }

    foreach (int i, m; kp.matches)
    {
        printLine(maxLines - i - 1, m);
    }
}

void printSelection(KeyProcessor kp)
{
    attron(A_BOLD);
    withColor(Colors.ARROW, delegate void() {
        if (kp.total > 0)
            mvprintw(kp.selected, 0, "> ");
    });
    attroff(A_BOLD);
}

void printTotalMatches(KeyProcessor kp)
{
    auto str = kp.total.to!string ~ "/" ~ kp.all.length.to!string;

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
