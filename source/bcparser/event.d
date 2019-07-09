/**
Parsing event module.
*/
module bcparser.event;

import bcparser.source : isSource, SourcePositionType;

/**
Event start prefix.
*/
enum EVENT_START_PREFIX = "start.";

/**
Event end prefix.
*/
enum EVENT_END_PREFIX = "end.";

/**
Parsing event.

Params:
    S = source type.
*/
struct ParsingEvent(S) if(isSource!S)
{
    /**
    Position type.
    */
    alias Position = SourcePositionType!S;

    /**
    Event name.
    */
    string name;

    /**
    Event position.
    */
    Position position;

    @property const @nogc nothrow pure @safe
    {
        /**
        Returns:
            true if this is node start event.
        */
        bool isStart() 
        {
            return name.startsWith!EVENT_START_PREFIX;
        }

        /**
        Returns:
            true if this is node end event.
        */
        bool isEnd()
        {
            return name.startsWith!EVENT_END_PREFIX;
        }

        /**
        Returns:
            true if this is node event.
        */
        bool isNode()
        {
            return isStart || isEnd;
        }

        /**
        Returns:
            node if this is node event else empty string.
        */
        string nodeName() return
        {
            if (isStart)
            {
                return name[EVENT_START_PREFIX.length .. $];
            }
            else if (isEnd)
            {
                return name[EVENT_END_PREFIX.length .. $];
            }
            else
            {
                return null;
            }
        }
    }
}

///
@nogc nothrow pure @safe unittest
{
    import bcparser.source : ArraySource;
    alias Source = ArraySource!char;
    alias Event = ParsingEvent!Source;

    immutable start = Event(EVENT_START_PREFIX ~ "test");
    assert(start.isStart);
    assert(!start.isEnd);
    assert(start.isNode);
    assert(start.nodeName == "test");
}

///
@nogc nothrow pure @safe unittest
{
    import bcparser.source : ArraySource;
    alias Source = ArraySource!char;
    alias Event = ParsingEvent!Source;

    immutable end = Event(EVENT_END_PREFIX ~ "test");
    assert(!end.isStart);
    assert(end.isEnd);
    assert(end.isNode);
    assert(end.nodeName == "test");
}

private:

/**
start with by string literal.

Params:
    P = prefix
    s = target string.
Returns:
    true if s starts with P.
*/
bool startsWith(string P)(scope string s) @nogc nothrow pure @safe
{
    if (s.length < P.length)
    {
        return false;
    }
    return s[0 .. P.length] == P[];
}

///
@nogc nothrow pure @safe unittest
{
    assert(startsWith!"test"("test"));
    assert(startsWith!"test"("testa"));
    assert(!startsWith!"test"(""));
    assert(!startsWith!"test"("tes"));
    assert(!startsWith!"test"("tesst"));
}

