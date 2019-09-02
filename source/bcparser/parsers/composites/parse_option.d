/**
Composite parser optional module.
*/
module bcparser.parsers.composites.parse_option;

import bcparser.context : isContext;
import bcparser.parsers.traits : isPrimitiveParser;
import bcparser.result : ParsingResult;

/**
parse using optional parser.

Params:
    P = inner parser.
*/
template parseOption(alias P)
{
    /**
    parse using optional parser.

    Params:
        C = context type.
        context = parsing context.
    Returns:
        true if no have error.
    */
    ParsingResult parseOption(C)(scope ref C context) @nogc nothrow @safe
    {
        static assert(isContext!C && isPrimitiveParser!(P, C));

        // discard result.
        auto result = P(context);
        return result | ParsingResult.match;
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
        assert(context.parseOption!((ref c) => c.parseChar('t')));
        
        // always true.
        assert(context.parseOption!((ref c) => c.parseChar('t')));
        assert(context.parseChar('e'));
    })(arraySource("test"), CAllocator());
}

