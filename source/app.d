import std.stdio;
import std.string : toStringz, strip;
import std.conv;
import std.typecons;
import std.algorithm;
import fuzzyd.core;
import deimos.ncurses.curses;

string[] parseStdin() {
  string l;
  string[] lines;
  while ((l = stdin.readln()) !is null)
    lines ~= strip(l);
  return lines;
}

enum KeyType {FUNCTION_KEY, WIDE_CHARACTER, UNKOWN};

struct Key {
  KeyType type;
  wint_t key;

  void get() {
    switch (get_wch(&key)) {
      case KEY_CODE_YES:
        type = KeyType.FUNCTION_KEY;
        break;
      case OK:
        type = KeyType.WIDE_CHARACTER;
        break;
      default:
        type = KeyType.UNKOWN;
    }
  }
}

void printMatches(scoreFn fzy, string pattern) {
  auto matches = fzy(pattern);
  matches = matches[0..min(10, matches.length)].reverse;
  foreach(int i, Result m; matches) {
    mvprintw(i+1, 0, toStringz(m.value));
  }
}

void loop(scoreFn fzy) {
  string pattern;
  auto key = Key();
  do {
    key.get();
    if (key.type is KeyType.WIDE_CHARACTER)
      pattern ~= to!char(key.key);
    else if (key.type is KeyType.FUNCTION_KEY) {
      if (key.key is KEY_BACKSPACE && pattern.length > 0)
        pattern = pattern[0..pattern.length-1];
    }
    clear();
    mvprintw(0, 0, toStringz("search: " ~ pattern));
    printMatches(fzy, pattern);
    refresh();
  } while(key.type != KeyType.UNKOWN);
}

int main() {
  auto fzy = fuzzy(parseStdin());

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

  loop(fzy);

  endwin();
  return 0;
}
