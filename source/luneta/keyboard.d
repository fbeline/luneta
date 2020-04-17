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
private:
    fuzzyFn _fuzzy;
    FuzzyResult[] _all;
    FuzzyResult[] _matches;
    int _selected, _cursorx;
    bool _dosearch;
    bool _terminate;
    Key _key;


public:
    string pattern;

    this(fuzzyFn fuzzy)
    {
        this._key = Key();
        this._dosearch = true;
        this._terminate = false;
        this._fuzzy = fuzzy;
        search;
    }

    final FuzzyResult[] matches() @property
    {
        return _matches;
    }

    final bool terminate() @property
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
        immutable index = getWindowSize() - _selected - 3;
        return matches[index].value;
    }

    final void getKey()
    {
        _key.get();
        _dosearch = true;

        if (_key.type is KeyType.WIDE_CHARACTER)
        {
            switch (_key.key)
            {
            case 10:
                _terminate = true;
                break;
            case 21:
                pattern = "";
                break;
            default:
                pattern ~= to!char(_key.key);
                _cursorx++;
            }
        }
        else if (_key.type is KeyType.FUNCTION_KEY)
        {
            specialHanlder();
        }
    }

    private final void specialHanlder()
    {
        switch (_key.key)
        {
        case KEY_BACKSPACE:
            if (!pattern.empty)
            {
                pattern = pattern[0 .. $ - 1];
                _cursorx--;
            }
            break;
        case KEY_DOWN:
            _selected = min(getWindowSize() - 3, _selected + 1);
            _dosearch = false;
            break;
        case KEY_UP:
            const yLimit = max(0, getWindowSize() - matches.length.to!int - 2);
            _selected = max(yLimit, _selected - 1);
            _dosearch = false;
            break;
        default:
            _dosearch = false;
        }
    }

    final void search()
    {
        if (!_dosearch)
            return;

        _all = _fuzzy(pattern);
        _matches = pattern.empty ? _all : _all.filter!(m => m.score > 0).array();
        _selected = getWindowSize() - 3;
    }
}
