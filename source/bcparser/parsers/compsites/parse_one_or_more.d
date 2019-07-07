/**
one or more parser module.
*/
module bcparser.parsers.composites.parse_one_or_more;

import bcparser.context : isContext;
import bcparser.parsers.traits : isPrimitiveParser;

/**
parse using one or more parser.

Params:
    P = inner parser.
    C = context type.
    source = parsing source.
Returns:
    true if matched one ore more times.
*/
bool parseOneOrMore(alias P, C)(ref C context) @nogc nothrow @safe
    if(isContext!C && isPrimitiveParser!((ref C c) => P(c)))
{
    if (!P(context)) {
        return false;
    }

    while(P(context)) {}
    return !context.hasError;
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;
    import bcparser.context : parse;
    import bcparser.parsers : parseChar;

    parse!((ref context) {
        // true if matched.
        assert(context.parseOneOrMore!((ref c) => c.parseChar('t')));
        
        // false if unmatched.
        assert(!context.parseOneOrMore!((ref c) => c.parseChar('t')));
        assert(context.parseChar('e'));
        assert(context.parseChar('s'));
        assert(context.parseChar('t'));

        // empty is false.
        assert(!context.parseOneOrMore!((ref c) => c.parseChar('t')));
    })(arraySource("test"), CAllocator());

    parse!((ref context) {
        // consume same chars.
        assert(context.parseOneOrMore!((ref c) => c.parseChar('t')));
        assert(context.parseChar('s'));
    })(arraySource("tttts"), CAllocator());
}

