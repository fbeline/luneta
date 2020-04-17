module luneta.window;

import std.stdio;
import std.algorithm;
import std.string : toStringz;
import deimos.ncurses.curses;

private const MAX_L = 22;

int getWindowSize()
{
    return min(MAX_L, getmaxy(stdscr));
}

void mvprintw(int line, int col, string str)
{
    deimos.ncurses.curses.mvprintw(line, col, toStringz(str));
}

void init(void delegate() loop)
{
    File tty = File("/dev/tty", "r+");
    SCREEN* screen = newterm(null, tty.getFP, tty.getFP);
    screen.set_term;
    scope (exit)
        endwin();
    cbreak;
    noecho;
    keypad(stdscr, true);

    refresh();

    loop();

    endwin();
}
