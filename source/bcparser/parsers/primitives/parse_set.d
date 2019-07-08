module bcparser.parsers.primitives.parse_set;

import bcparser.context : ContextElementType, isContext, tryParse;

/**
parse char in set.

Params:
    C = context type.
    CH = character type.
    context = parsing context.
    set = expected char set.
Returns:
    true if source has expected char in set.
*/
bool parseSet(C, CH)(scope ref C context, scope const(CH)[] set) @nogc nothrow @safe
    if(isContext!C && is(CH == ContextElementType!C))
{
    return context.tryParse!({
        CH c;
        if (!context.next(c))
        {
            return false;
        }

        foreach (e; set)
        {
            if (c == e)
            {
                return true;
            }
        }

        return false;
    });
}

///
@nogc nothrow @safe unittest
{
    import bcparser.context : parse;
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;

    parse!((ref context) {
        assert(!parseSet(context, "019"));
        assert(!parseSet(context, "ABZ"));
        assert(parseSet(context, "abz"));

        assert(!parseSet(context, "ABZ"));
        assert(!parseSet(context, "abz"));
        assert(parseSet(context, "019"));

        assert(!parseSet(context, "abz"));
        assert(!parseSet(context, "019"));
        assert(parseSet(context, "ABZ"));

        assert(!parseSet(context, "abz"));
        assert(!parseSet(context, "ABZ"));
        assert(parseSet(context, "019"));
    })(arraySource("a0Z9"), CAllocator());
}

