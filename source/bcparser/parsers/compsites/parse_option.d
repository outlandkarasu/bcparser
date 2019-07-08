/**
Composite parser optional module.
*/
module bcparser.parsers.composites.parse_option;

import bcparser.context : isContext;
import bcparser.parsers.traits : isPrimitiveParser;

/**
parse using optional parser.

Params:
    P = inner parser.
    C = context type.
    source = parsing source.
Returns:
    true if no have error.
*/
bool parseOption(alias P, C)(ref C context) @nogc nothrow @safe
    if(isContext!C && isPrimitiveParser!(P, C))
{
    // discard result.
    P(context);
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
        assert(context.parseOption!((ref c) => c.parseChar('t')));
        
        // always true.
        assert(context.parseOption!((ref c) => c.parseChar('t')));
        assert(context.parseChar('e'));
    })(arraySource("test"), CAllocator());
}

