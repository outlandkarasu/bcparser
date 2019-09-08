/**
Parsing context module.
*/
module bcparser.context;

import bcparser.event : EventType, ParsingEvent;
import bcparser.memory : add, isAllocator, release;
import bcparser.result : ParsingResult;
import bcparser.source :
    isSource,
    SourceElementType,
    SourcePositionType
;

import std.traits : ReturnType;

/**
Parsing context.

Params:
    S = source type.
    A = allocator type.
*/
struct Context(S, A)
{
    static assert(isSource!S);
    static assert(isAllocator!A);

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
        auto scope return ref A allocator)
    {
        this.source_ = source;
        this.allocator_ = allocator;
    }

    /**
    release saved memory.
    */
    ~this()
    {
        allocator_.release(events_);
    }

    /**
    get next element.

    Params:
        e = element dest.
    Returns:
        match if succeeded.
    */
    ParsingResult next(scope return out Element e)
    {
        if (hasError)
        {
            return errorState_;
        }

        immutable result = source_.next(e);
        if (result.hasError)
        {
            errorState_ = result;
        }
        return result;
    }

    /**
    add parsing event.

    Params:
        name = event name. (static value)
    Returns:
        match if succeeded.
    */
    ParsingResult addEvent(string name)()
    {
        return addEvent!(name, EventType.single)();
    }

    /**
    set on error at state saving.

    Returns:
        true if has internal error.
    */
    @property bool hasError() const @nogc nothrow pure @safe
    {
        return errorState_.hasError;
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
    add parsing event.

    Params:
        name = event name.
        type = event type.
    Returns:
        match if succeeded.
    */
    ParsingResult addEvent(string name, EventType type)()
    {
        if (hasError)
        {
            return errorState_;
        }

        if (!allocator_.add(events_, Event(name, source_.position, type)))
        {
            errorState_ = ParsingResult.createError("allocator error");
            return errorState_;
        }

        return ParsingResult.match;
    }

    /// parsing source.
    S source_;

    /// allocator.
    A allocator_;

    /// parsing events.
    Event[] events_;

    /// context error state.
    ParsingResult errorState_ = ParsingResult.match;
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;

    // parse source
    auto source = arraySource("test");
    auto allocator = CAllocator();
    auto context = Context!(typeof(source), typeof(allocator))(
            source, allocator);
    assert(context.events.length == 0);

    // fetch chars.
    char c;
    assert(context.next(c) && c == 't' && !context.hasError);
    assert(context.next(c) && c == 'e' && !context.hasError);

    // add parsing event.
    assert(context.addEvent!"event_a");
    assert(context.events.length == 1);
    assert(context.events[0].name == "event_a");
    assert(context.events[0].position == 2);

    // fetch rest chars.
    assert(context.next(c) && c == 's' && !context.hasError);
    assert(context.next(c) && c == 't' && !context.hasError);
    assert(!context.next(c) && c == char.init && !context.hasError);
}

/// test error from allocator handling.
@nogc nothrow @safe unittest
{
    import bcparser.memory : ErrorAllocator;
    import bcparser.source : arraySource;

    // parse source
    auto source = arraySource("test");
    auto allocator = ErrorAllocator();
    auto context = Context!(typeof(source), typeof(allocator))(
            source, allocator);

    // fetch chars.
    char c;
    assert(context.next(c) && c == 't' && !context.hasError);
    assert(context.next(c) && c == 'e' && !context.hasError);

    // add parsing event and error.
    assert(!context.addEvent!"event_a");
    assert(context.events.length == 0);
    assert(context.hasError);

    // fetch rest chars.
    assert(!context.next(c) && context.hasError);
}

/// test error from source handling.
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : ErrorSource;

    // parse source
    auto source = ErrorSource!char();
    auto allocator = CAllocator();
    auto context = Context!(typeof(source), typeof(allocator))(
            source, allocator);

    // fetch chars and error.
    char c;
    assert(context.next(c).hasError && context.hasError);

    // add parsing event and error.
    assert(!context.addEvent!"event_a");
    assert(context.events.length == 0);
    assert(context.hasError);
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
        auto scope ref A allocator)
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

/**
try parse.

Params:
    F = parse function.
    C = context type.
    c = context.
Returns:
    match if succeeded.
*/
ParsingResult tryParse(alias F, C)(ref C context)
{
    static assert(isContext!C);
    static assert(is(ReturnType!F : ParsingResult));

    immutable position = context.source_.position;
    immutable eventsLength = context.events_.length;
    immutable result = F();
    if (!result)
    {
        // parse failed. backtrack.
        context.source_.moveTo(position);
        if (eventsLength < context.events_.length)
        {
            context.allocator_.release(context.events_, eventsLength);
        }
    }
    return result;
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;

    parse!((ref context) {
        // accept and backtrack empty.
        assert(context.tryParse!(() => ParsingResult.match));
        assert(!context.tryParse!(() => ParsingResult.unmatch));

        // test backtrack.
        assert(!context.tryParse!({
            char c;
            assert(context.next(c) && c == 't' && !context.hasError);
            assert(context.next(c) && c == 'e' && !context.hasError);
            context.addEvent!("event_1");

            // backtrack.
            return ParsingResult.unmatch;
        }));
        assert(context.events.length == 0);

        // test accept.
        assert(context.tryParse!({
            char c;
            assert(context.next(c) && c == 't' && !context.hasError);
            assert(context.next(c) && c == 'e' && !context.hasError);
            context.addEvent!("event_2");

            // success.
            return ParsingResult.match;
        }));
        assert(context.events.length == 1);
        assert(context.events[0].name == "event_2");
        assert(context.events[0].position == 2);
    })(arraySource("test"), CAllocator());
}

/**
try parse node.

Params:
    name = node name.
    F = parse function.
    C = context type.
    c = context.
Returns:
    match if succeeded.
*/
ParsingResult tryParseNode(string name, alias F, C)(ref C context)
{
    static assert(isContext!C);
    static assert(is(ReturnType!F : ParsingResult));

    immutable position = context.source_.position;
    immutable eventsLength = context.events_.length;

    // start node.
    immutable nodeStartResult = context.addEvent!(name, EventType.nodeStart);
    if (!nodeStartResult)
    {
        return nodeStartResult;
    }

    // parse.
    immutable result = F();
    if (!result)
    {
        // parse failed. backtrack.
        context.source_.moveTo(position);
        if (eventsLength < context.events_.length)
        {
            context.allocator_.release(context.events_, eventsLength);
        }
        return result;
    }

    // end node.
    return context.addEvent!(name, EventType.nodeEnd);
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : arraySource;

    parse!((ref context) {
        // accept and backtrack empty.
        assert(context.tryParseNode!("test_node", () => ParsingResult.match));
        assert(context.events.length == 2);
        assert(context.events[0].name == "test_node");
        assert(context.events[0].isStart);
        assert(context.events[0].position == 0);
        assert(context.events[1].name == "test_node");
        assert(context.events[1].isEnd);
        assert(context.events[1].position == 0);
    })(arraySource("test"), CAllocator());
}

