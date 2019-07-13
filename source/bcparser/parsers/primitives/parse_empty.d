module bcparser.parsers.primitives.parse_empty;

import bcparser.context : isContext, ContextElementType, tryParse;
import bcparser.result : ParsingResult;

/**
parse empty source.

Params:
    C = context type.
    context = parsing context.
Returns:
    true if source is empty.
*/
ParsingResult parseEmpty(C)(scope ref C context) @nogc nothrow @safe if(isContext!C)
{
    ParsingResult result;
    context.tryParse!({
        ContextElementType!C c;
        result = ParsingResult.of(!context.next(c));
        return ParsingResult.unmatch;
    });
    return result;
}

///
@nogc nothrow @safe unittest
{
    import bcparser.context : parse;
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;

    parse!((ref context) {
        assert(!parseEmpty(context));
    })(arraySource("t"), CAllocator());

    parse!((ref context) {
        assert(parseEmpty(context));
    })(arraySource(""), CAllocator());
}

