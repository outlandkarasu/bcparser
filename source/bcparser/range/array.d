module bcparser.range.array;

/**
BetterC array range.

Params:
    E = element type.
*/
@nogc nothrow @safe
struct BetterCArrayRange(E)
{
    /**
    get front element.

    Returns:
        front element.
    */
    @property pure E front() const
    in
    {
        assert(!this.empty);
    }
    body
    {
        return array_[0];
    }

    @property pure typeof(this) save()
    {
        return typeof(this)(array_);
    }

    pure void popFront()
    in
    {
        assert(!this.empty);
    }
    body
    {
        array_ = array_[1 .. $];
    }

    @property pure bool empty() const
    {
        return array_.length == 0;
    }

private:
    E[] array_;
}

///
@nogc @safe unittest
{
    import std.algorithm : equal;
    import bcparser.range.traits : isBetterCForwardRange;

    static assert(isBetterCForwardRange!(BetterCArrayRange!ubyte));
    static assert(isBetterCForwardRange!(BetterCArrayRange!char));
    static assert(isBetterCForwardRange!(BetterCArrayRange!dchar));

    ubyte[4] a = [0, 1, 2, 3];
    auto r = BetterCArrayRange!ubyte(a);
    assert(r.equal(a[]));
    assert(r.front == 0);
    assert(!r.empty);
    assert(r.save.array_ == a);
}

@nogc @safe unittest
{
    import std.algorithm : equal;

    ubyte[4] a = [0, 1, 2, 3];
    auto r = BetterCArrayRange!ubyte(a);
    auto saved = r.save;
    r.popFront();
    assert(r.equal(a[1 .. $]));
    assert(saved.equal(a[]));

    r.popFront();
    assert(r.equal(a[2 .. $]));
    r.popFront();
    assert(r.equal(a[3 .. $]));
    r.popFront();
    assert(r.empty);
}

/**
create betterC array range.

Params:
    E = element type.
    array = wrapped array.
Returns:
    array range.
*/
BetterCArrayRange!E bcRange(E)(E[] array)
{
    return BetterCArrayRange!E(array);
}

///
@nogc @safe unittest
{
    import std.algorithm : equal;
    import bcparser.range.traits : isBetterCForwardRange;

    ubyte[4] a = [0, 1, 2, 3];
    auto r = bcRange(a);
    static assert(isBetterCForwardRange!(typeof(r)));
    assert(r.equal(a[]));
    assert(r.front == 0);
    assert(!r.empty);
    assert(r.save.array_ == a);
}

