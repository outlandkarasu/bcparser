module bcparser.parsers;

import bcparser.context :
    Context,
    ContextElementType,
    isContext,
    parse
;

/**
parse an any char.

Params:
    C = context type.
    context = parsing context.
*/
bool parseAny(C)(scope ref C context) @nogc nothrow @safe if(isContext!C)
{
    context.save();

    ContextElementType!C c;
    return context.next(c);
}

///
@nogc nothrow @safe unittest
{
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

/**
parse a char.

Params:
    C = context type.
    CH = character type.
    context = parsing context.
    expected = expected character.
*/
bool parseChar(C, CH)(scope ref C context, CH expected) @nogc nothrow @safe
    if(isContext!C && is(CH == ContextElementType!C))
{
    context.save();

    CH current;
    if (!context.next(current))
    {
        return false;
    }

    if (current != expected)
    {
        context.backtrack();
        return false;
    }

    return true;
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;

    parse!((ref context) {
        assert(!parseChar(context, 'a'));
        assert(parseChar(context, 't'));
        assert(!parseChar(context, 'b'));
        assert(parseChar(context, 'e'));
        assert(!parseChar(context, 'c'));
        assert(parseChar(context, 's'));
        assert(!parseChar(context, 'd'));
        assert(parseChar(context, 't'));
        assert(!parseChar(context, 't'));
    })(arraySource("test"), CAllocator());
}

