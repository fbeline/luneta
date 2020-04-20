module luneta.keyboard;

import std.conv;
import std.algorithm;
import std.array;
import deimos.ncurses.curses;
import luneta.window;
import fuzzyd.core;

/// pressed character type
enum KeyType
{
    FUNCTION_KEY,
    WIDE_CHARACTER,
    UNKOWN
}

/// read a character from the terminal and classify it's type
struct Key
{
    KeyType type; /// key type
    wint_t key; /// key value

    /// read a character from the terminal associated with the current or specified window
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
private:
    fuzzyFn _fuzzy;
    FuzzyResult[] _all;
    FuzzyResult[] _matches;
    int _selected, _cursorx;
    bool _dosearch;
    bool _terminate;
    Key _key;

    void buildPattern()
    {
        pattern.insertInPlace(cursorx, _key.key.to!string);
        cursorx = cursorx + 1;
    }

    void backspace()
    {
        if (pattern.empty)
            return;

        pattern.replaceInPlace(cursorx - 1, cursorx, "");
        cursorx = cursorx - 1;
    }

    void cursorx(int x) @property
    {
        _cursorx = max(0, x);
    }

    void specialHandler()
    {
        switch (_key.key)
        {
        case KEY_BACKSPACE:
            backspace;
            break;
        case KEY_DOWN:
            _selected = min(getWindowSize.height - 3, _selected + 1);
            _dosearch = false;
            break;
        case KEY_UP:
            const yLimit = max(0, getWindowSize.height - matches.length.to!int - 2);
            _selected = max(yLimit, _selected - 1);
            _dosearch = false;
            break;
        case KEY_LEFT:
            cursorx = cursorx - 1;
            break;
        case KEY_RIGHT:
            cursorx = min(pattern.length, cursorx + 1);
            break;
        default:
            _dosearch = false;
        }
    }

    void wideHandler()
    {
        switch (_key.key)
        {
        case 4:
        case 10:
            _terminate = true;
            break;
        case 1:
            cursorx = 0;
            break;
        case 5:
            cursorx = pattern.length.to!int;
            break;
        case 21:
            pattern = "";
            cursorx = 0;
            break;
        default:
            buildPattern;
        }
    }

public:
    string pattern;

    this(fuzzyFn fuzzy)
    {
        this._key = Key();
        this._dosearch = true;
        this._terminate = false;
        this._fuzzy = fuzzy;
        this.pattern = "";
        search;
    }

    final FuzzyResult[] matches() @property
    {
        return _matches;
    }

    final const bool terminate() @property
    {
        return _terminate;
    }

    final bool dosearch() @property
    {
        return _dosearch;
    }

    final int selected() @property
    {
        return _selected;
    }

    final Key key() @property
    {
        return _key;
    }

    final FuzzyResult[] all() @property
    {
        return _all;
    }

    final int cursorx() @property
    {
        return _cursorx;
    }

    final string getSelected()
    {
        immutable index = getWindowSize.height - _selected - 3;
        return matches[index].value;
    }

    final void getKey()
    {
        _key.get();
        _dosearch = true;

        if (_key.type is KeyType.WIDE_CHARACTER)
        {
            wideHandler();
        }
        else if (_key.type is KeyType.FUNCTION_KEY)
        {
            specialHandler();
        }
    }

    final void search()
    {
        if (!_dosearch)
            return;

        _all = _fuzzy(pattern);
        _matches = pattern.empty ? _all : _all.filter!(m => m.score > 0).array();
        _selected = getWindowSize.height - 3;
    }
}
