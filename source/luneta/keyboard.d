module luneta.keyboard;

import std.conv;
import std.algorithm;
import deimos.ncurses.curses;
import fuzzyd.core;

const MAX_PRINT = 20;
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
    string pattern;
    FuzzyResult[] allMatches;
    FuzzyResult[] matches;
    bool dosearch;
    bool terminate = false;
    Key key = Key();

    string getSelected()
    {
        immutable index = MAX_PRINT - selected - 1;
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
            if (pattern.length > 0)
                pattern = pattern[0 .. pattern.length - 1];
            break;
        case KEY_DOWN:
            selected = min(19, selected + 1);
            dosearch = false;
            break;
        case KEY_UP:
            immutable yLimit = max( 0, MAX_PRINT - matches.length.to!int);
            selected = max( yLimit, selected - 1);
            dosearch = false;
            break;
        default:
            dosearch = false;
        }
    }
}
