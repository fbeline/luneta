module luneta.window;

import std.stdio;
import std.string : toStringz, strip;
import deimos.ncurses.curses;

const MAX_L = 20;

void mvprintw(int line, int col, string str) {
    deimos.ncurses.curses.mvprintw(line, col, toStringz(str));
}

void init(void delegate() loop)
{
    File tty = File( "/dev/tty", "r+");
    SCREEN* screen = newterm( null, tty.getFP, tty.getFP);
    screen.set_term;
    scope (exit)
    endwin();
    cbreak;
    noecho;
    keypad( stdscr, true);

    mvprintw(0, 0, ">");
    refresh();

    loop();

    endwin();
}
