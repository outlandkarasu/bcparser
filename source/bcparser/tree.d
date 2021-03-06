/**
Tree module.
*/
module bcparser.tree;

import bcparser.context : Context;
import bcparser.event : ParsingEvent;
import bcparser.source : isSource, SourcePositionType;

/**
Params:
    H = event handler.
    S = source type.
Returns:
    true if H is event handler.
*/
enum bool isEventHandler(alias H, S) =
    isSource!S
    && is(typeof((scope string name) {
        auto start = SourcePositionType!S.init;
        auto end = SourcePositionType!S.init;
        size_t depth;
        H(name, start, end, depth);
    }));

///
@nogc nothrow pure @safe unittest
{
    import bcparser.source : ArraySource;
    static assert(isEventHandler!((name, start, end, depth) {}, ArraySource!char));
    static assert(!isEventHandler!((name, start, end) {}, ArraySource!char));
    static assert(!isEventHandler!((char name, start, end, depth) {}, ArraySource!char));
    static assert(!isEventHandler!((name, start, end, depth) {}, int));
}

/**
walk event tree.

Params:
    H = event handler.
    S = source type.
    context = context.
Returns:
    true if succeeded.
*/
bool walkEventTree(alias H, S, A)(ref scope const(Context!(S, A)) context)
    if (isEventHandler!(H, S))
{
    return walkEventArray!H(context.events);
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.context : parse, tryParseNode;
    import bcparser.result : ParsingResult;
    import bcparser.source : arraySource;

    // walk single event
    parse!((ref context) {
        context.addEvent!("test_event");
        assert(walkEventTree!((name, start, end, depth) {
            assert(name == "test_event");
            assert(start == 0);
            assert(end == 0);
            assert(depth == 0);
        })(context));
    })(arraySource("test"), CAllocator());

    // walk node event
    parse!((ref context) {
        char c;
        context.tryParseNode!("test_node", {
            assert(context.next(c));
            return ParsingResult.match;
        });

        assert(walkEventTree!((name, start, end, depth) {
            assert(name == "test_node");
            assert(start == 0);
            assert(end == 1);
            assert(depth == 0);
        })(context));
    })(arraySource("test"), CAllocator());

    // walk nested node event
    parse!((ref context) {
        char c;
        context.tryParseNode!("test_node", {
            assert(context.next(c));
            assert(context.tryParseNode!("child_node", {
                assert(context.next(c));
                return ParsingResult.match;
            }));
            assert(context.next(c));
            return ParsingResult.match;
        });

        assert(walkEventTree!((name, start, end, depth) {
            if (name == "test_node")
            {
                assert(start == 0);
                assert(end == 3);
                assert(depth == 0);
            }
            else if (name == "child_node")
            {
                assert(start == 1);
                assert(end == 2);
                assert(depth == 1);
            }
            else
            {
                assert(false);
            }
        })(context));
    })(arraySource("test"), CAllocator());
}

private:

/**
walk event array function.

Params:
    H = event handler.
    S = source type.
    events = event array.
Returns:
    true if succeeded.
*/
bool walkEventArray(alias H, S)(const(ParsingEvent!S)[] events) if (isEventHandler!(H, S))
{
    auto tempEvents = events;
    if (!walkEventArrayWithDepth!H(tempEvents, 0))
    {
        return false;
    }
    return tempEvents.length == 0;
}

@nogc nothrow @safe unittest
{
    import bcparser.event : EventType, ParsingEvent;
    import bcparser.source : ArraySource;

    alias Source = ArraySource!char;
    alias Event = ParsingEvent!Source;

    // error at missing start node.
    Event[1] endOnlyEvents = [ Event("invalid_node", 0, EventType.nodeEnd) ];
    assert(!walkEventArray!((name, start, end, depth) { assert(false); })(
        endOnlyEvents));

    // error at missing end node.
    Event[1] startOnlyEvents = [ Event("invalid_node", 0, EventType.nodeEnd) ];
    assert(!walkEventArray!((name, start, end, depth) { assert(false); })(
        startOnlyEvents));

    // error at missing nested start node.
    Event[3] missingNestedStartEvents = [
        Event("parent_node", 0, EventType.nodeStart),
        Event("invalid_node", 1, EventType.nodeEnd),
        Event("parent_node", 2, EventType.nodeEnd),
    ];
    assert(!walkEventArray!((name, start, end, depth) { assert(false); })(
        missingNestedStartEvents));

    // error at missing nested end node.
    Event[3] missingNestedEndEvents = [
        Event("parent_node", 0, EventType.nodeStart),
        Event("invalid_node", 1, EventType.nodeStart),
        Event("parent_node", 2, EventType.nodeEnd),
    ];
    assert(!walkEventArray!((name, start, end, depth) { assert(false); })(
        missingNestedEndEvents));
}

/**
walk event tree.

Params:
    H = event handler.
    S = source type.
    events = parsing event array.
    depth = current depth.
Returns:
    true if succeeded.
*/
bool walkEventArrayWithDepth(alias H, S)(
        scope ref const(ParsingEvent!S)[] events, size_t depth)
    if (isEventHandler!(H, S))
{
    for (; events.length > 0; events = events[1 .. $])
    {
        immutable event = events[0];
        if (event.isStart)
        {
            immutable start = event.position;
            immutable name = event.name;
            events = events[1 .. $];
            if (!walkEventArrayWithDepth!(H, S)(events, depth + 1))
            {
                return false;
            }

            if (events.length == 0)
            {
                return false;
            }

            immutable end = events[0];
            if (!end.isEnd || end.name != name)
            {
                return false;
            }

            H(name, start, end.position, depth);
        }
        else if (event.isEnd)
        {
            break;
        }
        else
        {
            // single event.
            H(event.name, event.position, event.position, depth);
        }
    }

    return true;
}

