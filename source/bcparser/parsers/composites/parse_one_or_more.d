/**
one or more parser module.
*/
module bcparser.parsers.composites.parse_one_or_more;

import bcparser.context : isContext;
import bcparser.parsers.traits : isPrimitiveParser;
import bcparser.result : ParsingResult;

/**
parse using one or more parser.

Params:
    P = inner parser.
*/
template parseOneOrMore(alias P)
{
    /**
    parse using one or more parser.

    Params:
        C = context type.
        context = parsing context.
    Returns:
        true if matched one ore more times.
    */
    ParsingResult parseOneOrMore(C)(scope ref C context)
    {
        static assert(isContext!C);
        static assert(isPrimitiveParser!(P, C));

        ParsingResult headResult = P(context);
        if (!headResult)
        {
            return headResult;
        }

        ParsingResult tailResult;
        do
        {
            tailResult = P(context);
        }
        while(tailResult);
        return headResult | tailResult;
    }
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

