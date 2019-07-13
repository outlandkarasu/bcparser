/**
Composite parser not module.
*/
module bcparser.parsers.composites.parse_not;

import bcparser.context : isContext, tryParse;
import bcparser.parsers.traits : isPrimitiveParser;
import bcparser.result : ParsingResult;

/**
parse using not parser.

Params:
    P = inner parser.
    C = context type.
    source = parsing source.
Returns:
    true if unmatched.
*/
ParsingResult parseNot(alias P, C)(ref C context) @nogc nothrow @safe
    if(isContext!C && isPrimitiveParser!(P, C))
{
    ParsingResult result;
    context.tryParse!({
        result = P(context);
        return ParsingResult.unmatch;
    });
    return result.hasError ?  result : ParsingResult.of(!result);
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;
    import bcparser.context : parse;
    import bcparser.parsers : parseChar;

    parse!((ref context) {
        // false if matched.
        assert(!context.parseNot!((ref c) => c.parseChar('t')));

        // true if matched.
        assert(context.parseNot!((ref c) => c.parseChar('e')));
        
        // not consume chars.
        assert(!context.parseNot!((ref c) => c.parseChar('t')));
        assert(context.parseNot!((ref c) => c.parseChar('e')));
        assert(context.parseChar('t'));
        assert(context.parseChar('e'));
        assert(context.parseChar('s'));
        assert(context.parseChar('t'));
    })(arraySource("test"), CAllocator());
}

