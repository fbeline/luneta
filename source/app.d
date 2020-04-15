import std.stdio;
import std.string : toStringz, strip;
import std.conv;
import std.typecons;
import std.algorithm;
import std.array;
import fuzzyd.core;
import deimos.ncurses.curses;

const int MAX_PRINT = 20;

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

void printMatches(FuzzyResult[] matches, int selected) {

  void printLine(int line, FuzzyResult m) {
    for(int i; i < m.value.length; i++) {
      if (m.matches.canFind(i)) {
        attron(A_BOLD);
        mvprintw(line, i + 2, toStringz(m.value[i].to!string));
        attroff(A_BOLD);
      } else {
        mvprintw(line, i + 2, toStringz(m.value[i].to!string));
      }
    }
  }

  for(int i; i < min(MAX_PRINT, matches.length); i++) {
    immutable int lineNumber = MAX_PRINT - i - 1;
    if (lineNumber is selected) {
      attron(A_REVERSE);
      printLine(lineNumber, matches[i]);
      attroff(A_REVERSE);
    } else {
      printLine(lineNumber, matches[i]);
    }
  }
}

void printSelection(KeyProcessor kp) {
  attron(A_REVERSE);
  immutable stopLine = max(0, MAX_PRINT - kp.matches.length);
  for(int i = MAX_PRINT-1; i > stopLine; i--)
    mvprintw(i, 0, toStringz(" "));
  if (kp.matches.length > 0)
    mvprintw(kp.selected, 0, toStringz("> "));
  attroff(A_REVERSE);
}

void printTotalMatches(KeyProcessor kp) {
  auto str = (to!string(kp.matches.length) ~
              "/" ~
              to!string(kp.allMatches.length)).toStringz;

  attron(A_BOLD);
  mvprintw(MAX_PRINT, 1, str);
  attroff(A_BOLD);
}

struct KeyProcessor {
  int selected;
  string pattern;
  FuzzyResult[] allMatches;
  FuzzyResult[] matches;
  bool dosearch;
  bool terminate = false;
  Key key = Key();

  string getSelected() {
    immutable index = MAX_PRINT - selected;
    return matches[index].value;
  }

  void getKey() {
    key.get();
    dosearch = true;

    if (key.type is KeyType.WIDE_CHARACTER) {
      if (key.key is 10) {
        terminate = true;
      } else {
        pattern ~= to!char(key.key);
      }
    } else if (key.type is KeyType.FUNCTION_KEY) {
      specialHanlder();
    }
  }

  void specialHanlder() {
    switch(key.key) {
      case KEY_BACKSPACE:
        if (pattern.length > 0) pattern = pattern[0..pattern.length-1];
        break;
      case KEY_DOWN:
        selected = min(19, selected+1);
        dosearch = false;
        break;
      case KEY_UP:
        selected = max(0, selected-1);
        dosearch = false;
        break;
      default:
        dosearch = false;
    }
  }
}

alias loopFn = void delegate ();
loopFn loop(fuzzyFn fzy, ref string result) {
  return delegate void() {
    auto kp = KeyProcessor();
    do {
      kp.getKey();
      clear();
      if (kp.terminate) {
        result = kp.getSelected;
        break;
      }
      if (kp.dosearch) {
        kp.allMatches = fzy(kp.pattern);
        kp.matches = kp.allMatches.filter!(m => m.score > 0).array();
        kp.selected = MAX_PRINT-1;
      }
      printMatches(kp.matches, kp.selected);
      printSelection(kp);
      printTotalMatches(kp);
      mvprintw(MAX_PRINT+1, 0, toStringz("> " ~ kp.pattern));
      refresh();
    } while(kp.key.type != KeyType.UNKOWN);
  };
}

void cursesInit(loopFn loop) {
  File tty = File("/dev/tty", "r+");
  SCREEN* screen = newterm(null, tty.getFP, tty.getFP);
  screen.set_term;
  scope (exit) endwin();
  cbreak;
  noecho;
  keypad(stdscr, true);

  mvprintw(1, 0, toStringz("> "));
  refresh();

  loop();

  endwin();
}

int main() {
  auto fzy = fuzzy(parseStdin());
  string result;
  cursesInit(loop(fzy, result));
  write(result);
  return 0;
}
