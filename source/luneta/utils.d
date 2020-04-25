module luneta.utils;

import std.uni;
import std.conv;
import std.range;

/// insert dchar at given index
string insertAt(string str, int index, dchar c)
{
    int i;
    dchar[] result;

    if (index >= str.walkLength)
        return str ~ c.to!string;

    foreach (s; str.byCodePoint)
    {
        if (i is index)
            result ~= c;
        result ~= s;
        i++;
    }

    return result.to!string;
}

/// delete codepoint at index
string deleteAt(string str, int index)
{
    int i;
    dchar[] result;

    foreach (s; str.byCodePoint)
    {
        if (i !is index)
            result ~= s;
        i++;
    }

    return result.to!string;
}
