/**
Parsing events module.
*/
module bcparser.event.event;

/**
Parsing event.
*/
struct ParsingEvent
{
    /// event tag name.
    string tag;

    /// event position.
    size_t position;

    /**
    Returns:
        true if end element.
    */
    @nogc nothrow @property pure @safe bool end() const 
    {
        return next is null;
    }

private:
    ParsingEvent* next;
}

/**
Append last event to list.

Params:
    next = next element.
    element = appended element.
Returns:
    appended element.
*/
@nogc nothrow pure @safe
ref ParsingEvent appendTo(
    return ref scope ParsingEvent element,
    ParsingEvent* next)
in
{
    assert(next !is null);
    assert(element !is *next);
}
body
{
    element.next = next;
    return element;
}

///
@nogc nothrow pure @safe unittest
{
    auto event1 = ParsingEvent("test1", 100);
    assert(event1.tag == "test1");
    assert(event1.position == 100);
    assert(event1.next is null);
    assert(event1.end);

    // for using pointer in @nogc @safe, use local array.
    ParsingEvent[1] events = [ParsingEvent("test2", 200)];
    event1.appendTo(&events[0]);
    assert(event1.next == &events[0]);
    assert(!event1.end);
}

