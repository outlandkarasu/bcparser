module bcparser.range;

import std.range :
    isForwardRange,
    isInputRange;

/**
Returns `true` if `R` is a BetterC forward range.
*/
enum bool isBetterCInputRange(R) =
    isInputRange!R
    && is(typeof((R r) @nogc nothrow => r.empty))
    && is(typeof((R r) @nogc nothrow => r.front))
    && is(typeof((R r) @nogc nothrow => r.popFront));

///
@nogc nothrow @safe unittest
{
    @safe struct Range
    {
        nothrow @property pure char front() const { return char.init; }
        nothrow pure void popFront() { }
        nothrow @property pure bool empty() const { return false; }
    }
    static assert(isBetterCInputRange!Range);

    version (D_BetterC) { }
    else
    {
        @safe struct FrontNoBCRange
        {
            nothrow @property pure char front() const { new Object; return char.init; }
            @nogc nothrow pure void popFront() { }
            @nogc nothrow @property pure bool empty() const { return false; }
        }
        static assert(!isBetterCInputRange!FrontNoBCRange);

        @safe struct PopFrontNoBCRange
        {
            @nogc nothrow @property pure char front() const { return char.init; }
            nothrow pure void popFront() { new Object; }
            @nogc nothrow @property pure bool empty() const { return false; }
        }
        static assert(!isBetterCInputRange!PopFrontNoBCRange);

        @safe struct EmptyNoBCRange
        {
            @nogc nothrow @property pure char front() const { return char.init; }
            @nogc nothrow pure void popFront() { }
            nothrow @property pure bool empty() const { new Object; return false; }
        }
        static assert(!isBetterCInputRange!EmptyNoBCRange);
    }
}

/**
Returns `true` if `R` is a BetterC forward range.
*/
enum bool isBetterCForwardRange(R) =
    isForwardRange!R
    && is(typeof((R r) @nogc nothrow => r.empty))
    && is(typeof((R r) @nogc nothrow => r.front))
    && is(typeof((R r) @nogc nothrow => r.popFront))
    && is(typeof((R r) @nogc nothrow => r.save));

///
@nogc nothrow @safe unittest
{
    @safe struct Range
    {
        nothrow @property pure char front() const { return char.init; }
        nothrow @property pure Range save() { return this; }
        nothrow pure void popFront() { }
        nothrow @property pure bool empty() const { return false; }
    }
    static assert(isBetterCForwardRange!Range);

    version (D_BetterC) { }
    else
    {
        @safe struct FrontNoBCRange
        {
            nothrow @property pure char front() const { new Object; return char.init; }
            @nogc nothrow @property pure typeof(this) save() { return this; }
            @nogc nothrow pure void popFront() { }
            @nogc nothrow @property pure bool empty() const { return false; }
        }
        static assert(!isBetterCForwardRange!FrontNoBCRange);

        @safe struct SaveNoBCRange
        {
            @nogc nothrow @property pure char front() const { return char.init; }
            nothrow @property pure typeof(this) save() { new Object; return this; }
            @nogc nothrow pure void popFront() { }
            @nogc nothrow @property pure bool empty() const { return false; }
        }
        static assert(!isBetterCForwardRange!SaveNoBCRange);

        @safe struct PopFrontNoBCRange
        {
            @nogc nothrow @property pure char front() const { return char.init; }
            @nogc nothrow @property pure typeof(this) save() { return this; }
            nothrow pure void popFront() { new Object; }
            @nogc nothrow @property pure bool empty() const { return false; }
        }
        static assert(!isBetterCForwardRange!PopFrontNoBCRange);

        @safe struct EmptyNoBCRange
        {
            @nogc nothrow @property pure char front() const { return char.init; }
            @nogc nothrow @property pure typeof(this) save() { return this; }
            @nogc nothrow pure void popFront() { }
            nothrow @property pure bool empty() const { new Object; return false; }
        }
        static assert(!isBetterCForwardRange!EmptyNoBCRange);
    }
}

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

