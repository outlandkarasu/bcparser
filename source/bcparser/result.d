module bcparser.result;

import bcparser.range.traits : isBetterCForwardRange;

/**
parsing result.

Params:
    R = range type.
*/
struct Result(R) if (isBetterCForwardRange!R)
{
    /**
    true if matched parser.
    */
    bool match;

    /**
    next source range.
    */
    R next;
}

/**
call chain if matched.

Params:
    F = function.
    R = range type.
    result = map result.
Returns:
    mapped function result.
*/
R map(alias F, R)(return ref scope R result)
{
    if (result.match)
    {
        return F(result.next);
    }
    return result;
}

///
@nogc nothrow pure @safe unittest
{
    import bcparser.range : bcRange;

    int[4] source = [0, 1, 2, 3];
    auto r = bcRange(source);
    alias Res = Result!(typeof(r));

    auto matchedResult = Res(true, r);
    assert(matchedResult.match);

    auto unmatchedResult = Res(false, r);
    assert(!unmatchedResult.match);

    auto mappedResult = matchedResult.map!((a) {
        a.popFront();
        return Res(true, a);
    });
    assert(mappedResult.match);
    assert(mappedResult.next.front == 1);

    auto unmappedResult = unmatchedResult.map!((a) {
        a.popFront();
        return Res(true, a);
    });
    assert(!unmappedResult.match);
    assert(unmappedResult.next.front == 0);
}

