/**
zero or more parser module.
*/
module bcparser.parsers.composites.parse_zero_or_more;

import bcparser.context : isContext;
import bcparser.parsers.traits : isPrimitiveParser;
import bcparser.result : ParsingResult;

/**
parse using zero or more parser.

Params:
    P = inner parser.
    C = context type.
    source = parsing source.
Returns:
    true if no have error.
*/
template parseZeroOrMore(alias P)
{
    /**
    parse using zero or more parser.

    Params:
        P = inner parser.
        C = context type.
        source = parsing source.
    Returns:
        true if no have error.
    */
    ParsingResult parseZeroOrMore(C)(scope ref C context) @nogc nothrow @safe
        if(isContext!C && isPrimitiveParser!(P, C))
    {
        ParsingResult result;
        while ((result = P(context)).isMatch) {}
        return ParsingResult.match | result;
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
        assert(context.parseZeroOrMore!((ref c) => c.parseChar('t')));
        
        // always true.
        assert(context.parseZeroOrMore!((ref c) => c.parseChar('t')));
        assert(context.parseChar('e'));
        assert(context.parseChar('s'));
        assert(context.parseChar('t'));

        // empty but true.
        assert(context.parseZeroOrMore!((ref c) => c.parseChar('t')));
    })(arraySource("test"), CAllocator());

    parse!((ref context) {
        // consume same chars.
        assert(context.parseZeroOrMore!((ref c) => c.parseChar('t')));
        assert(context.parseChar('s'));
    })(arraySource("tttts"), CAllocator());
}

