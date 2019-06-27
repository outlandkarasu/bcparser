/**
Parsing source for array.
*/
module bcparser.source.array;

/**
Array source.
*/
struct ArraySource(E)
{
    /**
    construct by an array range.

    Params:
        array = source array.
    */
    this(const(E)[] array) @nogc nothrow pure @safe
    {
        this.array_ = array;
    }

    bool next(return scope out E e) @nogc nothrow pure @safe
    {
        if (position_ >= array_.length)
        {
            return false;
        }

        e = array_[position_];
        ++position_;
        return true;
    }

    @property size_t position() const @nogc nothrow pure @safe
    {
        return position_;
    }

    void moveTo(size_t position) @nogc nothrow pure @safe
    {
        position_ = (array_.length < position)
            ? array_.length : position;
    }

private:
    const(E)[] array_;
    size_t position_ = 0;
}

///
@nogc nothrow pure @safe unittest
{
    import bcparser.source.traits : isSource;

    auto source = ArraySource!(char)("test");
    static assert(isSource!(typeof(source)));

    char c;
    assert(source.position == 0);
    assert(source.next(c) && source.position == 1 && c == 't');
    assert(source.next(c) && source.position == 2 && c == 'e');
    assert(source.next(c) && source.position == 3 && c == 's');
    assert(source.next(c) && source.position == 4 && c == 't');
    assert(!source.next(c) && c == c.init);

    source.moveTo(0);
    assert(source.next(c) && source.position == 1 && c == 't');

    source.moveTo(3);
    assert(source.next(c) && source.position == 4 && c == 't');
    assert(!source.next(c) && c == c.init);
}

