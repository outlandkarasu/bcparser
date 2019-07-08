/**
Sequence parser module.
*/
module bcparser.parsers.composites.parse_sequence;

import bcparser.context : isContext, tryParse;
import bcparser.parsers.traits : isPrimitiveParser;

/**
parse using sequence parser.

Params:
    P = parser sequence.
*/
template parseSequence(P...)
{
    /**
    parse using sequence parser.

    Params:
        C = context type.
        source = parsing source.
    Returns:
        true if matched all parsers.
    */
    bool parseSequence(C)(ref C context) @nogc nothrow @safe
        if(isContext!C && is(typeof(
        {
            foreach (p; P)
            {
                static assert(isPrimitiveParser!(p, C));
            }
        })))
    {
        return context.tryParse!({
            foreach(parser; P)
            {
                if(!parser(context))
                {
                    return false;
                }
            }
            return true;
        });
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
        assert(context.parseSequence!(
            (ref c) => c.parseChar('t'),
            (ref c) => c.parseChar('e'),
            (ref c) => c.parseChar('s'),
            (ref c) => c.parseChar('t')));
    })(arraySource("test"), CAllocator());

    parse!((ref context) {
        assert(!context.parseSequence!(
            (ref c) => c.parseChar('t'),
            (ref c) => c.parseChar('e'),
            (ref c) => c.parseChar('t'),
            (ref c) => c.parseChar('t')));

        // revert source if unmatched.
        assert(context.parseChar('t'));
        assert(context.parseChar('e'));
        assert(context.parseChar('s'));
        assert(context.parseChar('t'));
    })(arraySource("test"), CAllocator());
}

