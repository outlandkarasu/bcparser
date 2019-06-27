/**
Parsing context module.
*/
module bcparser.context;

import bcparser.source :
    isSource,
    SourceElementType,
    SourcePositionType
;

import bcparser.memory : isAllocator;

/**
Parsing context.

Params:
    S = source type.
    A = allocator type.
*/
struct Context(S, A) if(isSource!S && isAllocator!A)
{
    /// element type.
    alias Element = SourceElementType!S;

    @disable this();
    @disable this(this);

    /**
    construct from a source and an allocator.

    Params:
        source = parsing source.
        allocator = memory allocator.
    */
    this()(
        auto scope return ref S source,
        auto scope return ref A allocator) @nogc nothrow pure @safe
    {
        this.source_ = source;
        this.allocator_ = allocator;
    }

    /**
    get next element.

    Params:
        e = element dest.
    Returns:
        true if succeeded.
    */
    bool next(scope return out Element e) @nogc nothrow pure @safe
    {
        return source_.next(e);
    }

private:

    /// parsing source.
    S source_;

    /// allocator.
    A allocator_;
}

/**
construct parsing context.

Params:
    S = source type.
    A = memory allocator type.
    source = parsing source.
    allocator = memory allocator.
Returns:
    parsing context.
*/
@nogc nothrow pure @safe
auto context(S, A)(
    auto scope return ref S source,
    auto scope return ref A allocator)
{
    return Context!(S, A)(source, allocator);
}

///
@nogc nothrow pure @safe unittest
{
    import bcparser.source : ArraySource;
    import bcparser.memory : CAllocator;

    auto source = ArraySource!char("test");
    auto allocator = CAllocator();
    auto context = context(source, allocator);

    char c;
    assert(context.next(c) && c == 't');
    assert(context.next(c) && c == 'e');
    assert(context.next(c) && c == 's');
    assert(context.next(c) && c == 't');
    assert(!context.next(c) && c == char.init);
}

private:

/**
Parsing state.
*/
struct State(S) if (isSource!S)
{
    /// saved position.
    SourcePositionType!S position;

    /// saved event length.
    size_t eventLength;
}

