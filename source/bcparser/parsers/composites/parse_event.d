/**
Event parser module.
*/
module bcparser.parsers.composites.parse_event;

import bcparser.context : isContext, tryParseNode;
import bcparser.parsers.traits : isPrimitiveParser;
import bcparser.result : ParsingResult;

/**
parse using optional parser.

Params:
    name = event name.
    P = inner parser.
*/
template parseEvent(string name, alias P)
{
    /**
    parse using optional parser.

    Params:
        C = context type.
        context = parsing context.
    Returns:
        true if no have error.
    */
    ParsingResult parseEvent(C)(scope ref C context) @nogc nothrow @safe
    {
        static assert(isContext!C && isPrimitiveParser!(P, C));

        return context.tryParseNode!(name, () => P(context));
    }
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;
    import bcparser.context : parse;
    import bcparser.parsers : parseChar;
    import bcparser.event : EventType, ParsingEvent;

    parse!((ref context) {
        alias Ctx = typeof(context);

        // true if matched.
        assert(context.parseEvent!("testEvent", (ref c) => c.parseChar('t')));
        assert(context.events.length == 2);
        assert(context.events[0] == Ctx.Event("testEvent", 0, EventType.nodeStart));
        assert(context.events[1] == Ctx.Event("testEvent", 1, EventType.nodeEnd));
    })(arraySource("test"), CAllocator());

    parse!((ref context) {
        alias Ctx = typeof(context);

        // false and empty events if unmatched.
        assert(!context.parseEvent!("testEvent", (ref c) => c.parseChar('b')));
        assert(context.events.length == 0);
    })(arraySource("test"), CAllocator());
}

