module bcparser.parsers.parse_empty;

import bcparser.context : isContext, ContextElementType;

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
    context.save();

    ContextElementType!C c;
    immutable result = !context.next(c);

    context.backtrack();
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

