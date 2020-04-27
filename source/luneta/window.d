module luneta.window;

import std.stdio;
import std.algorithm;
import std.string : toStringz;
public import deimos.ncurses;
import luneta.opts;
import core.stdc.locale;

/// Terminal colors
enum Colors
{
    SELECTION,
    MATCH
}

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
    deimos.ncurses.mvprintw(line, col, toStringz(str));
}

/// configure ncurses and start application loop
void init(void delegate() loop)
{
    setlocale(LC_ALL, "");
    File tty = File("/dev/tty", "r+");
    newterm(null, tty.getFP, tty.getFP);

    scope (failure)
        endwin;
    scope (exit)
        endwin;

    cbreak;
    noecho;
    keypad(stdscr, true);
    startColor;

    refresh;
    loop();

    endwin;
}

void WITH_COLOR(void delegate() fn)
{
    attron(COLOR_PAIR(1));
    fn();
    attroff(COLOR_PAIR(1));
}

private:

void startColor()
{
    start_color();
    init_pair(1, COLOR_RED, COLOR_BLACK);
    // init_pair(Colors.MATCH, COLOR_WHITE, COLOR_BLUE);
}
