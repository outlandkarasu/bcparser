/**
Parsing event module.
*/
module bcparser.event;

import bcparser.source : isSource, SourcePositionType;

/**
event type.
*/
enum EventType
{
    /// single event.
    single,

    /// node start.
    nodeStart,

    /// node end.
    nodeEnd,
}

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
            return type_ == EventType.nodeStart;
        }

        /**
        Returns:
            true if this is node end event.
        */
        bool isEnd()
        {
            return type_ == EventType.nodeEnd;
        }

        /**
        Returns:
            true if this is node event.
        */
        bool isNode()
        {
            return isStart || isEnd;
        }
    }

private:
    EventType type_;
}

///
@nogc nothrow pure @safe unittest
{
    import bcparser.source : ArraySource;
    alias Source = ArraySource!char;
    alias Event = ParsingEvent!Source;

    immutable start = Event("test", 0, EventType.nodeStart);
    assert(start.isStart);
    assert(!start.isEnd);
    assert(start.isNode);
    assert(start.name == "test");
}

///
@nogc nothrow pure @safe unittest
{
    import bcparser.source : ArraySource;
    alias Source = ArraySource!char;
    alias Event = ParsingEvent!Source;

    immutable end = Event("test", 0, EventType.nodeEnd);
    assert(!end.isStart);
    assert(end.isEnd);
    assert(end.isNode);
    assert(end.name == "test");
}

///
@nogc nothrow pure @safe unittest
{
    import bcparser.source : ArraySource;
    alias Source = ArraySource!char;
    alias Event = ParsingEvent!Source;

    immutable single = Event("test", 0, EventType.single);
    assert(!single.isStart);
    assert(!single.isEnd);
    assert(!single.isNode);
    assert(single.name == "test");
}

