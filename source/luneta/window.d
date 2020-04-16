module luneta.window;

import std.stdio;
import std.string : toStringz, strip;
import deimos.ncurses.curses;

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

    mvprintw( 1, 0, toStringz( "> "));
    refresh();

    loop();

    endwin();
}
