import std.stdio;
import std.string : toStringz, strip;
import std.conv;
import std.typecons;
import fuzzyd.core;
import deimos.ncurses.curses;

string[] parseStdin() {
  string l;
  string[] lines;
  while ((l = stdin.readln()) !is null)
    lines ~= strip(l);
  return lines;
}

enum KeyType {SPECIAL, NORMAL, UNKOWN};

struct Key {
  KeyType type;
  wint_t key;

  void get() {
    switch (get_wch(&key)) {
      case KEY_CODE_YES:
        type = KeyType.SPECIAL;
        break;
      case OK:
        type = KeyType.NORMAL;
        break;
      default:
        type = KeyType.UNKOWN;
    }
  }
}


int main() {
  auto f = fuzzy(parseStdin());

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

  string pattern;
  auto key = Key();
  do {
    key.get();
    if (key.type == KeyType.NORMAL) pattern ~= to!char(key.key);
    // mvprintw(10, 0, toStringz(key.key.to!string));
    mvprintw(0, 0, toStringz("search: " ~ pattern));
    refresh();
  } while(key.type != KeyType.UNKOWN);

  endwin();
  return 0;
}
