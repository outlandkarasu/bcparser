module bcparser.parsers.primitives.parse_any;

import bcparser.context : ContextElementType, isContext;
import bcparser.result : ParsingResult;

/**
parse an any char.

Params:
    C = context type.
    context = parsing context.
Returns:
    match if source has any char.
*/
ParsingResult parseAny(C)(scope ref C context)
{
    static assert(isContext!C);

    ContextElementType!C c;
    return context.next(c);
}

///
@nogc nothrow @safe unittest
{
    import bcparser.context : parse;
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;

    parse!((ref context) {
        assert(parseAny(context));
        assert(parseAny(context));
        assert(parseAny(context));
        assert(parseAny(context));
        assert(!parseAny(context));
    })(arraySource("test"), CAllocator());
}

