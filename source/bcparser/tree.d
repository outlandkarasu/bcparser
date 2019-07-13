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
    && is(typeof((scope string name) @nogc nothrow @safe {
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
bool walkEventTree(alias H, S, A)(
        ref scope const(Context!(S, A)) context) @nogc nothrow @safe
    if (isEventHandler!(H, S))
{
    auto events = context.events;
    if (!walkEventTree!H(events, 0))
    {
        return false;
    }

    return events.length == 0;
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.context : parse;
    import bcparser.event : EVENT_END_PREFIX, EVENT_START_PREFIX;
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
        context.addEvent!(EVENT_START_PREFIX ~ "test_node");
        assert(context.next(c));
        context.addEvent!(EVENT_END_PREFIX ~ "test_node");

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
        context.addEvent!(EVENT_START_PREFIX ~ "test_node");
        assert(context.next(c));
        context.addEvent!(EVENT_START_PREFIX ~ "child_node");
        assert(context.next(c));
        context.addEvent!(EVENT_END_PREFIX ~ "child_node");
        assert(context.next(c));
        context.addEvent!(EVENT_END_PREFIX ~ "test_node");

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

@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.context : parse;
    import bcparser.event : EVENT_END_PREFIX, EVENT_START_PREFIX;
    import bcparser.source : arraySource;

    // error at missing start node.
    parse!((ref context) {
        context.addEvent!(EVENT_END_PREFIX ~ "invalid_node");
        assert(!walkEventTree!((name, start, end, depth) {
            // never call.
            assert(false);
        })(context));
    })(arraySource("test"), CAllocator());

    // error at missing end node.
    parse!((ref context) {
        context.addEvent!(EVENT_START_PREFIX ~ "invalid_node");
        assert(!walkEventTree!((name, start, end, depth) {
            // never call.
            assert(false);
        })(context));
    })(arraySource("test"), CAllocator());

    // error at missing nested start node.
    parse!((ref context) {
        char c;
        context.addEvent!(EVENT_START_PREFIX ~ "node");
        assert(context.next(c));
        context.addEvent!(EVENT_END_PREFIX ~ "invalid_child");
        assert(context.next(c));
        context.addEvent!(EVENT_END_PREFIX ~ "node");
        assert(!walkEventTree!((name, start, end, depth) {
            // never call.
            assert(false);
        })(context));
    })(arraySource("test"), CAllocator());

    // error at missing nested end node.
    parse!((ref context) {
        char c;
        context.addEvent!(EVENT_START_PREFIX ~ "node");
        assert(context.next(c));
        context.addEvent!(EVENT_START_PREFIX ~ "invalid_child");
        assert(context.next(c));
        context.addEvent!(EVENT_END_PREFIX ~ "node");
        assert(!walkEventTree!((name, start, end, depth) {
            // never call.
            assert(false);
        })(context));
    })(arraySource("test"), CAllocator());
}

private:

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
bool walkEventTree(alias H, S)(
        scope ref const(ParsingEvent!S)[] events,
        size_t depth) @nogc nothrow @safe
    if (isEventHandler!(H, S))
{
    for (; events.length > 0; events = events[1 .. $])
    {
        immutable event = events[0];
        if (event.isStart)
        {
            immutable start = event.position;
            immutable name = event.nodeName;
            events = events[1 .. $];
            if (!walkEventTree!(H, S)(events, depth + 1))
            {
                return false;
            }

            if (events.length == 0)
            {
                return false;
            }

            immutable end = events[0];
            if (!end.isEnd || end.nodeName != name)
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

