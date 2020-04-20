module luneta.window;

import std.stdio;
import std.algorithm;
import std.string : toStringz;
import deimos.ncurses.curses;

private const MAX_L = 22;

/// window size
struct Wsize
{
    int width; /// window width
    int height; /// window height
}

/// get window size
Wsize getWindowSize()
{
    return Wsize(getmaxx(stdscr), min(MAX_L, getmaxy(stdscr)));
}

/// ncurses mvprintw wrapper
void mvprintw(int line, int col, string str)
{
    deimos.ncurses.curses.mvprintw(line, col, toStringz(str));
}

/// configure ncurses and start application loop
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
