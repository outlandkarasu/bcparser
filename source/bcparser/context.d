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

    /// event type.
    alias Event = ParsingEvent!S;

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
        allocator_.release(savedStates_);
        allocator_.release(events_);
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
        allocator_.release(savedStates_, savedStates_.length - 1);
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
    @property bool hasError() const @nogc nothrow pure @safe
    {
        return hasError_;
    }

    /**
    Returns:
        current events.
    */
    @property const(Event)[] events() const @nogc nothrow pure return @safe
    {
        return events_;
    }

private:

    /**
    Parsing state.
    */
    struct State
    {
        /// saved position.
        SourcePositionType!S position;

        /// saved event length.
        size_t eventLength;
    }

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

/// backtrack test.
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;

    auto source = arraySource("test");
    auto allocator = CAllocator();
    auto context = Context!(typeof(source), typeof(allocator))(
            source, allocator);
    assert(context.events.length == 0);

    char c;
    assert(context.next(c) && c == 't' && !context.hasError);
    assert(context.next(c) && c == 'e' && !context.hasError);

    assert(context.addEvent!"event_a");
    assert(context.events.length == 1);
    assert(context.events[0].name == "event_a");
    assert(context.events[0].position == 2);

    assert(context.save());
    assert(context.next(c) && c == 's' && !context.hasError);
    assert(context.next(c) && c == 't' && !context.hasError);
    assert(!context.next(c) && c == char.init && !context.hasError);

    assert(context.addEvent!"event_b");
    assert(context.events.length == 2);
    assert(context.events[1].name == "event_b");
    assert(context.events[1].position == 4);

    context.backtrack();

    assert(context.next(c) && c == 's' && !context.hasError);
    assert(context.next(c) && c == 't' && !context.hasError);
    assert(!context.next(c) && c == char.init && !context.hasError);
    assert(context.events.length == 1);
    assert(context.events[0].name == "event_a");
    assert(context.events[0].position == 2);
}

/**
Params:
    C = target type.
Returns:
    true if C is context.
*/
enum isContext(C) = is(C: Context!(S, A), S, A);

///
@nogc nothrow pure @safe unittest
{
    import bcparser.source : ArraySource;
    import bcparser.memory : CAllocator;

    static assert(!isContext!int);
    static assert(isContext!(Context!(ArraySource!char, CAllocator)));
}

/**
context element type.

Params:
    C = context type.
    S = source type.
    A = allocator type.
*/
template ContextElementType(C : Context!(S, A), S, A) {
    alias ContextElementType = C.Element;
}

///
@nogc nothrow @safe unittest
{
    import bcparser.source : arraySource;
    import bcparser.memory : CAllocator;

    auto source = arraySource("test");
    auto allocator = CAllocator();
    auto context = Context!(typeof(source), typeof(allocator))(
        source, allocator);

    static assert(is(ContextElementType!(typeof(context)) == char));
}

/**
Params:
    F = parse function.
    S = source type.
    A = allocator type.
    source = target source.
    allocator = target allocator.
*/
void parse(alias F, S, A)(
    auto scope ref S source,
    auto scope ref A allocator) @nogc nothrow @safe
{
    auto context = Context!(S, A)(source, allocator);
    F(context);
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;

    parse!((ref context) {
        char c;
        assert(context.next(c) && c == 't' && !context.hasError);
        assert(context.next(c) && c == 'e' && !context.hasError);
        assert(context.next(c) && c == 's' && !context.hasError);
        assert(context.next(c) && c == 't' && !context.hasError);
        assert(!context.next(c) && c == char.init && !context.hasError);
    })(arraySource("test"), CAllocator());
}

