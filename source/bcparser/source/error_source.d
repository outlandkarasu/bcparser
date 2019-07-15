/**
Error source for test.
*/
module bcparser.source.error_source;

import bcparser.result : ParsingResult;

/**
Error source.
*/
struct ErrorSource(E)
{
    /**
    Always return error.

    Params:
        e = next char.
    Returns:
        parsing error.
    */
    ParsingResult next(return scope out E e) @nogc nothrow pure @safe
    {
        return ParsingResult.createError("ErrorSource");
    }

    /**
    Returns:
        current position.
    */
    @property size_t position() const @nogc nothrow pure @safe
    {
        return position_;
    }

    /**
    move to position.
    Params:
        position = next position.
    */
    void moveTo(size_t position) @nogc nothrow pure @safe
    {
        position_ = position;
    }

private:
    size_t position_ = 0;
}

///
@nogc nothrow pure @safe unittest
{
    import bcparser.source.traits : isSource;

    auto source = ErrorSource!char();
    static assert(isSource!(typeof(source)));

    char c;
    assert(source.position == 0);
    assert(source.next(c).hasError && source.position == 0);
    source.moveTo(1);
    assert(source.next(c).hasError && source.position == 1);
}

