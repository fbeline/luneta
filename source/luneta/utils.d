module luneta.utils;

import std.stdio;
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

@("On insertAt")
unittest {
    const s = "aple";
    const result =  s.insertAt(1, 'p');
    const expected = "apple";
    assert(expected == result);
}

@("If index is greater than string length insert char at the end of the string")
unittest {
    const s = "orang";
    const result =  s.insertAt(20, 'e');
    const expected = "orange";
    assert(expected == result);
}

@("On deleteAt")
unittest {
    const s = "appple";
    const result =  s.deleteAt(1);
    const expected = "apple";
    assert(expected == result);
}

@("Do nothing if index is greater than string length")
unittest {
    const s = "orange";
    const result =  s.deleteAt(16);
    const expected = "orange";
    writeln(result);
    assert(expected == result);
}