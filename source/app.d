import std.stdio;
import std.string : toStringz, strip;
import std.conv;
import fuzzyd.core;
import deimos.ncurses.curses;

int main()
{
  string l;
  string[] lines;
  while ((l = stdin.readln()) !is null)
    lines ~= strip(l);
  auto f = fuzzy(lines);
  auto cmd = toStringz(f("cd")[0].value);

  // immutable msg = toStringz("hello world");

  File tty = File("/dev/tty", "r+");
	SCREEN* screen = newterm(null, tty.getFP, tty.getFP);
  screen.set_term;
  scope (exit)
    endwin();
  cbreak();
  noecho();
	keypad(stdscr, true);

	mvprintw(0, 0, toStringz("search: "));
  refresh();

  int key;
  string pattern;
  while((key = getch()) != ERR) {
    clear();
    pattern ~= key;
    mvprintw(10, 0, toStringz(to!string(key)));
    mvprintw(0, 0, toStringz("search: " ~ pattern));
    refresh();
  }

  endwin();

  return 0;
}
