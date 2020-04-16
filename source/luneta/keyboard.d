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

struct KeyProcessor
{
    int selected;
    string[] input;
    string pattern;
    FuzzyResult[] allMatches;
    FuzzyResult[] matches;
    bool dosearch = true;
    bool terminate = false;
    Key key = Key();

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

    void specialHanlder()
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
}
