/**
Event parser module.
*/
module bcparser.parsers.composites.parse_event;

import bcparser.context : isContext, tryParse;
import bcparser.event : EVENT_END_PREFIX, EVENT_START_PREFIX;
import bcparser.parsers.traits : isPrimitiveParser;

/**
parse using optional parser.

Params:
    name = event name.
    P = inner parser.
    C = context type.
    source = parsing source.
Returns:
    true if no have error.
*/
bool parseEvent(string name, alias P, C)(ref C context) @nogc nothrow @safe
    if(isContext!C && isPrimitiveParser!(P, C))
{
    return context.tryParse!({
        context.addEvent!(EVENT_START_PREFIX ~ name);

        if (!P(context))
        {
            return false;
        }

        context.addEvent!(EVENT_END_PREFIX ~ name);
        return !context.hasError;
    });
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;
    import bcparser.context : parse;
    import bcparser.parsers : parseChar;
    import bcparser.event : ParsingEvent;

    parse!((ref context) {
        alias Ctx = typeof(context);

        // true if matched.
        assert(context.parseEvent!("testEvent", (ref c) => c.parseChar('t')));
        assert(context.events.length == 2);
        assert(context.events[0] == Ctx.Event("start.testEvent", 0));
        assert(context.events[1] == Ctx.Event("end.testEvent", 1));
    })(arraySource("test"), CAllocator());

    parse!((ref context) {
        alias Ctx = typeof(context);

        // false and empty events if unmatched.
        assert(!context.parseEvent!("testEvent", (ref c) => c.parseChar('b')));
        assert(context.events.length == 0);
    })(arraySource("test"), CAllocator());
}

