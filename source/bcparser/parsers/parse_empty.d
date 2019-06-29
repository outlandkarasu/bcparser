module bcparser.parsers.parse_empty;

import bcparser.context : isContext, ContextElementType, tryParse;

/**
parse empty source.

Params:
    C = context type.
    context = parsing context.
Returns:
    true if source is empty.
*/
bool parseEmpty(C)(scope ref C context) @nogc nothrow @safe if(isContext!C)
{
    bool result;
    context.tryParse!({
        ContextElementType!C c;
        result = !context.next(c);
        return false;
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

