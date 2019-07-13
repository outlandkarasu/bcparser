/**
Always error allocator.
*/
module bcparser.memory.error_allocator;

import bcparser.memory.allocator : isAllocator;

/**
Always error allocator.
*/
struct ErrorAllocator
{
    /**
    Allocate memory.

    Params:
        memory = allocated memory destination.
        n = allocation bytes.
    Returns:
        true if succeeded.
    */
    bool allocate(scope return out void[] memory, size_t n) @nogc nothrow @safe
    {
        return false;
    }

    /**
    Resize allocated memory.

    Params:
        memory = resizing memory.
        n = new length.
    Returns:
        true if succeeded.
    */
    bool resize(scope return ref void[] memory, size_t n) @nogc nothrow @safe
    in
    {
        assert(memory !is null);
    }
    body
    {
        return false;
    }

    /**
    Free allocated memory.

    Params:
        memory = freeing memory. to empty when function succeeded.
    */
    void free(scope return ref void[] memory) @nogc nothrow @safe
    out
    {
        assert(memory is null);
    }
    body
    {
        // do nothing.
    }
}

static assert(isAllocator!ErrorAllocator);

///
@nogc nothrow @trusted unittest
{
    auto allocator = ErrorAllocator();
    void[] array;
    assert(!allocator.allocate(array, 5));

    ubyte[5] bytes;
    array = bytes[];
    assert(!allocator.resize(array, 5));
}

