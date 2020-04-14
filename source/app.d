import std.stdio;
import std.string : toStringz, strip;
import std.conv;
import std.typecons;
import std.algorithm;
import std.array;
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

Result[] fuzzySearch(scoreFn fzy, string pattern) {
  auto matches = fzy(pattern);
  return matches[0..min(10, matches.length)]
    .reverse
    .filter!(m => m.score > 0)
    .array();
}

void printMatches(Result[] matches, int selected) {
  foreach(int i, Result m; matches) {
    if (i is selected) {
      attron(A_REVERSE);
      mvprintw(i, 1, toStringz("  " ~ m.value));
      attroff(A_REVERSE);
    } else {
      mvprintw(i, 3, toStringz(m.value));
    }
  }
}

void printSelection(int count, int selected) {
  attron(A_REVERSE);
  for(int i = 0; i <= count-1; i++)
    mvprintw(i, 0, toStringz(" "));
  mvprintw(selected, 0, toStringz(">"));
  attroff(A_REVERSE);
}

struct KeyProcessor {
  int selected;
  int count;
  string pattern;
  Result[] matches;
  bool dosearch;
  bool terminate = false;
  Key key = Key();

  void getKey() {
    key.get();
    dosearch = true;
    if (key.type is KeyType.WIDE_CHARACTER)
      pattern ~= to!char(key.key);
    else if (key.type is KeyType.FUNCTION_KEY) {
      specialHanlder();
    }
  }

  void specialHanlder() {
    if (key.key is KEY_BACKSPACE && pattern.length > 0)
      pattern = pattern[0..pattern.length-1];
    else if (key.key is KEY_UP) {
      selected = max(0, selected-1);
      dosearch = false;
    } else if (key.key is KEY_DOWN) {
      selected = min(count-1, selected+1);
      dosearch = false;
    }
  }
}

void loop(scoreFn fzy) {
  auto kp = KeyProcessor();
  do {
    kp.getKey();
    clear();
    if (kp.dosearch) {
      kp.matches = fuzzySearch(fzy, kp.pattern);
      kp.count = to!int(kp.matches.length);
      kp.selected = kp.count-1;
    }
    printMatches(kp.matches, kp.selected);
    printSelection(kp.count, kp.selected);
    mvprintw(kp.count+1, 0, toStringz("> " ~ kp.pattern));
    refresh();
  } while(kp.key.type != KeyType.UNKOWN);
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

  mvprintw(1, 0, toStringz("> "));
  refresh();

  loop(fzy);

  endwin();
  return 0;
}
