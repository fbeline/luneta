module luneta.keyboard;

import std.conv;
import std.algorithm;
import std.array;
import deimos.ncurses.curses;
import luneta.window;
import fuzzyd.core;

enum KeyType
{
    FUNCTION_KEY,
    WIDE_CHARACTER,
    UNKOWN
};

struct Key
{
    KeyType type;
    wint_t key;

    void get()
    {
        switch (get_wch(&key))
        {
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

class KeyProcessor
{
    fuzzyFn fuzzy;
    int selected;
    string[] input;
    string pattern;
    FuzzyResult[] all;
    FuzzyResult[] matches;
    bool dosearch;
    bool terminate;
    Key key;

    this(fuzzyFn fuzzy) {
        this.key = Key();
        this.dosearch = true;
        this.terminate = false;
        this.fuzzy = fuzzy;
        search;
    }

    string getSelected()
    {
        immutable index = getWindowSize() - selected - 3;
        return matches[index].value;
    }

    void getKey()
    {
        key.get();
        dosearch = true;

        if (key.type is KeyType.WIDE_CHARACTER)
        {
            if (key.key is 10)
            {
                terminate = true;
            }
            else
            {
                pattern ~= to!char(key.key);
            }
        }
        else if (key.type is KeyType.FUNCTION_KEY)
        {
            specialHanlder();
        }
    }

    private void specialHanlder()
    {
        switch (key.key)
        {
        case KEY_BACKSPACE:
            if (!pattern.empty)
                pattern = pattern[0 .. $ - 1];
            break;
        case KEY_DOWN:
            selected = min(getWindowSize() - 3, selected + 1);
            dosearch = false;
            break;
        case KEY_UP:
            immutable yLimit = max(0, getWindowSize() - matches.length.to!int - 2);
            selected = max(yLimit, selected - 1);
            dosearch = false;
            break;
        default:
            dosearch = false;
        }
    }

    void search()
    {
        if (!dosearch) return;

        all = fuzzy(pattern);
        matches = pattern.empty ? all : all.filter!(m => m.score > 0).array();
        selected = getWindowSize() - 3;
    }
}
