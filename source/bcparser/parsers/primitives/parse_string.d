module bcparser.parsers.primitives.parse_string;

import bcparser.context : ContextElementType, isContext, tryParse;

/**
parse string.

Params:
    C = context type.
    CH = character type.
    context = parsing context.
    expected = expected string.
Returns:
    true if source has expected string.
*/
bool parseString(C, CH)(scope ref C context, scope const(CH)[] expected) @nogc nothrow @safe
    if(isContext!C && is(CH == ContextElementType!C))
{
    return context.tryParse!({
        foreach (e; expected)
        {
            CH c;
            if (!context.next(c) || c != e)
            {
                // unmatch char.
                return false;
            }
        }

        // succeeded.
        return true;
    });
}

///
@nogc nothrow @safe unittest
{
    import bcparser.context : parse;
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;

    parse!((ref context) {
        assert(!parseString(context, "ab"));
        assert(!parseString(context, "tb"));
        assert(!parseString(context, "ae"));
        assert(parseString(context, "te"));
        assert(parseString(context, "st"));
        assert(!parseString(context, "st"));
        assert(parseString(context, ""));
    })(arraySource("test"), CAllocator());
}

