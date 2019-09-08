module bcparser.parsers.primitives.parse_char;

import bcparser.context : ContextElementType, isContext, tryParse;
import bcparser.result : ParsingResult;

/**
parse a char.

Params:
    C = context type.
    CH = character type.
    context = parsing context.
    expected = expected character.
Returns:
    match if source has expected char.
*/
ParsingResult parseChar(C, CH)(scope ref C context, CH expected)
{
    static assert(isContext!C);
    static assert(is(CH == ContextElementType!C));

    return context.tryParse!({
        CH current;
        if (!context.next(current))
        {
            return ParsingResult.unmatch;
        }

        if (current != expected)
        {
            return ParsingResult.unmatch;
        }

        return ParsingResult.match;
    });
}

///
@nogc nothrow @safe unittest
{
    import bcparser.context : parse;
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

