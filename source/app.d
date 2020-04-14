import std.stdio;
import std.string : toStringz, strip;
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

  printw(cmd);
  refresh();

  getch();
  endwin();

  return 0;
}
