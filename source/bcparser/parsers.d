module bcparser.parsers;

import bcparser.range : isBetterCForwardRange;

@nogc nothrow pure @safe:

/**
Params:
    r = target range.
Returns:
    true if r has any element.
*/
bool parseAny(R)(auto ref R r) if (isBetterCForwardRange!R)
{
    if (!r.empty)
    {
        r.popFront();
        return true;
    }

    return false;
}

///
@nogc nothrow pure @safe unittest
{
    import bcparser.range : BetterCArrayRange;
    import std.algorithm : equal;

    int[3] source = [0, 1, 2];
    auto r = BetterCArrayRange!int(source);
    assert(r.parseAny);
    assert(r.equal(source[1 .. $]));
    assert(r.parseAny);
    assert(r.equal(source[2 .. $]));
    assert(r.parseAny);
    assert(r.empty);
    assert(!r.parseAny);
}

