/**
Ordered choice parser module.
*/
module bcparser.parsers.composites.parse_choice;

import bcparser.context : isContext;
import bcparser.parsers.traits : isPrimitiveParser;
import bcparser.result : ParsingResult;

/**
parse using ordered choice parser.

Params:
    P = ordered choice parsers.
*/
template parseChoice(P...)
{
    /**
    parse using choice parser.

    Params:
        C = context type.
        source = parsing source.
    Returns:
        true if matched all parsers.
    */
    ParsingResult parseChoice(C)(scope ref C context)
    {
        static assert(isContext!C);
        static assert(is(typeof(
        {
            foreach (p; P)
            {
                static assert(isPrimitiveParser!(p, C));
            }
        }
        )));

        foreach(parser; P)
        {
            immutable result = parser(context);
            if(!result.isUnmatch)
            {
                return result;
            }
        }

        return ParsingResult.unmatch;
    }
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;
    import bcparser.context : parse;
    import bcparser.parsers : parseChar;

    // match character sequence.
    parse!((ref context) {
        alias p = parseChoice!(
            (ref c) => c.parseChar('t'),
            (ref c) => c.parseChar('e'),
            (ref c) => c.parseChar('s'),
            (ref c) => c.parseChar('t'));

        assert(p(context));
        assert(p(context));
        assert(p(context));
        assert(p(context));
        assert(!p(context)); // empty.
    })(arraySource("test"), CAllocator());

    parse!((ref context) {
        alias p = parseChoice!(
            (ref c) => c.parseChar('t'),
            (ref c) => c.parseChar('e'),
            (ref c) => c.parseChar('s'),
            (ref c) => c.parseChar('t'));

        assert(!p(context));
        assert(context.parseChar('a'));
    })(arraySource("atest"), CAllocator());
}

