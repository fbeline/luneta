import std.stdio;
import std.string : toStringz, strip;
import std.conv;
import std.typecons;
import std.algorithm;
import std.array;
import fuzzyd.core;
import deimos.ncurses.curses;
import printers;
import keyboard;

const MAX_PRINT = 20;

string[] parseStdin() {
  string l;
  string[] lines;
  while ((l = stdin.readln()) !is null)
    lines ~= strip(l);
  return lines;
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
