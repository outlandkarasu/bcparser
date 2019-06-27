/**
Parsing context module.
*/
module bcparser.context;

import bcparser.event : ParsingEvent;
import bcparser.memory : add, isAllocator, release;
import bcparser.source :
    isSource,
    SourceElementType,
    SourcePositionType
;


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
    release saved memory.
    */
    ~this() @nogc nothrow @safe
    {
        void[] memory = savedStates_;
        allocator_.free(memory);
        savedStates_ = null;

        memory = events_;
        allocator_.free(memory);
        events_ = null;
    }

    /**
    get next element.

    Params:
        e = element dest.
    Returns:
        true if succeeded.
    */
    bool next(scope return out Element e) @nogc nothrow pure @safe
    in
    {
        assert(!hasError);
    }
    body
    {
        if (hasError_)
        {
            return false;
        }
        return source_.next(e);
    }

    /**
    save current state for backtrack.

    Returns:
        true if succeeded.
    */
    bool save() @nogc nothrow @trusted
    in
    {
        assert(!hasError);
    }
    out(result)
    {
        // has error if failed.
        assert(result || hasError);
    }
    body
    {
        if (hasError_)
        {
            return false;
        }

        if (!allocator_.add(
                savedStates_, State(source_.position, events_.length)))
        {
            hasError_ = true;
            return false;
        }

        return true;
    }

    /**
    backtrack to last saved state.
    */
    void backtrack() @nogc nothrow @trusted
    in
    {
        assert(savedStates_.length > 0);
    }
    body
    {
        // restore last state.
        auto state = savedStates_[$ - 1];
        source_.moveTo(state.position);
        events_ = events_[0 .. state.eventLength];

        // remove last state.
        void[] memory = savedStates_;
        allocator_.resize(memory, memory.length - State.sizeof);
        savedStates_ = cast(State[]) memory;
    }

    /**
    add parsing event.

    Params:
        name = event name. (static value)
    Returns:
        true if succeeded.
    */
    bool addEvent(string name)() @nogc nothrow @safe
    {
        return allocator_.add(events_, Event(name, source_.position));
    }

    /**
    set on error at state saving.

    Returns:
        true if has internal error.
    */
    @property hasError() const @nogc nothrow pure @safe
    {
        return hasError_;
    }

private:

    alias Event = ParsingEvent!S;
    alias State = ParsingState!S;

    /// parsing source.
    S source_;

    /// allocator.
    A allocator_;

    /// saved states.
    State[] savedStates_;

    /// parsing events.
    Event[] events_;

    /// error flag.
    bool hasError_;
}

///
@nogc nothrow @safe unittest
{
    import bcparser.source : ArraySource;
    import bcparser.memory : CAllocator;

    auto source = ArraySource!char("test");
    auto allocator = CAllocator();
    auto context = Context!(typeof(source), typeof(allocator))(
            source, allocator);

    char c;
    assert(context.next(c) && c == 't' && !context.hasError);
    assert(context.next(c) && c == 'e' && !context.hasError);
    assert(context.next(c) && c == 's' && !context.hasError);
    assert(context.next(c) && c == 't' && !context.hasError);
    assert(!context.next(c) && c == char.init && !context.hasError);
}

/// backtrack test.
@nogc nothrow @safe unittest
{
    import bcparser.source : ArraySource;
    import bcparser.memory : CAllocator;

    auto source = ArraySource!char("test");
    auto allocator = CAllocator();
    auto context = Context!(typeof(source), typeof(allocator))(
            source, allocator);

    char c;
    assert(context.next(c) && c == 't' && !context.hasError);
    assert(context.next(c) && c == 'e' && !context.hasError);
    assert(context.addEvent!"event_a");

    assert(context.save());
    assert(context.next(c) && c == 's' && !context.hasError);
    assert(context.next(c) && c == 't' && !context.hasError);
    assert(!context.next(c) && c == char.init && !context.hasError);
    assert(context.addEvent!"event_b");

    context.backtrack();

    assert(context.next(c) && c == 's' && !context.hasError);
    assert(context.next(c) && c == 't' && !context.hasError);
    assert(!context.next(c) && c == char.init && !context.hasError);
}


private:

/**
Parsing state.
*/
struct ParsingState(S) if (isSource!S)
{
    /// saved position.
    SourcePositionType!S position;

    /// saved event length.
    size_t eventLength;
}

