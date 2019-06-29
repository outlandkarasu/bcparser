module bcparser.parsers.parse_string;

import bcparser.context : ContextElementType, isContext;

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
    context.save();
    return false;
}

/+
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
+/

