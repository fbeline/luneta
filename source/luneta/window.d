module luneta.window;

import std.stdio;
import std.algorithm;
import std.string : toStringz;
public import deimos.ncurses.curses;
import luneta.opts;
import core.stdc.locale;

/// window size
struct Wsize
{
    int width; /// window width
    int height; /// window height
}

/// get window size
Wsize getWindowSize()
{
    return Wsize(getmaxx(stdscr), min(luneta.opts.height, getmaxy(stdscr)));
}

/// ncurses mvprintw wrapper
void mvprintw(int line, int col, string str)
{
    deimos.ncurses.curses.mvprintw(line, col, toStringz(str));
}

/// configure ncurses and start application loop
void init(void delegate() loop)
{
    setlocale(LC_ALL, "");
    File tty = File("/dev/tty", "r+");
    newterm(null, tty.getFP, tty.getFP);
    scope (exit)
        endwin();
    cbreak;
    noecho;
    keypad(stdscr, true);

    refresh();

    loop();

    endwin();
}
