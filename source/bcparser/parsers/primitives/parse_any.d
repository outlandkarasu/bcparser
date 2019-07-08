module bcparser.parsers.primitives.parse_any;

import bcparser.context : ContextElementType, isContext;

/**
parse an any char.

Params:
    C = context type.
    context = parsing context.
Returns:
    true if source has any char.
*/
bool parseAny(C)(scope ref C context) @nogc nothrow @safe if(isContext!C)
{
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

