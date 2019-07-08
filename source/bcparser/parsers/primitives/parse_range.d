module bcparser.parsers.primitives.parse_range;

import bcparser.context : ContextElementType, isContext, tryParse;

/**
parse char in range.

Params:
    C = context type.
    CH = character type.
    context = parsing context.
    l = expected char range (lower).
    h = expected char range (higher).
Returns:
    true if source has expected char in range.
*/
bool parseRange(C, CH)(scope ref C context, CH l, CH h) @nogc nothrow @safe
    if(isContext!C && is(CH == ContextElementType!C))
{
    return context.tryParse!({
        CH c;
        return context.next(c) && (l <= c && c <= h);
    });
}

///
@nogc nothrow @safe unittest
{
    import bcparser.context : parse;
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;

    parse!((ref context) {
        // match lower alphabet.
        assert(!parseRange(context, '0', '9'));
        assert(!parseRange(context, 'A', 'Z'));
        assert(parseRange(context, 'a', 'z'));

        // match digits.
        assert(!parseRange(context, 'A', 'Z'));
        assert(!parseRange(context, 'a', 'z'));
        assert(parseRange(context, '0', '9'));

        // match upper alphabet.
        assert(parseRange(context, 'A', 'Z'));

        // match digits.
        assert(parseRange(context, '0', '9'));

        // not match empty source.
        assert(!parseRange(context, '0', '9'));
        assert(!parseRange(context, 'A', 'Z'));
        assert(!parseRange(context, 'a', 'z'));
    })(arraySource("a0Z9"), CAllocator());
}
