/**
Allocator using standard C API.
*/
module bcparser.memory.c_allocator;

import bcparser.memory.allocator : isAllocator;

/**
Allocator using standard C API.
*/
struct CAllocator
{
    private import core.stdc.stdlib : free, malloc, realloc;

    /**
    Allocate memory.

    Params:
        memory = allocated memory destination.
        n = allocation bytes.
    Returns:
        true if succeeded.
    */
    bool allocate(scope out void[] memory, size_t n) @nogc nothrow @trusted
    {
        auto p = malloc(n);
        if (!p)
        {
            return false;
        }

        memory = p[0 .. n];
        return true;
    }

    /**
    Resize allocated memory.

    Params:
        memory = resizing memory.
        n = new length.
    Returns:
        true if succeeded.
    */
    bool resize(scope ref void[] memory, size_t n) @nogc nothrow @trusted
    in
    {
        assert(memory !is null);
    }
    body
    {
        auto newMemory = realloc(&memory[0], n);
        if (!newMemory)
        {
            return false;
        }

        memory = newMemory[0 .. n];
        return true;
    }

    /**
    Free allocated memory.

    Params:
        memory = freeing memory. to empty when function succeeded.
    */
    void free(scope ref void[] memory) @nogc nothrow @trusted
    out
    {
        assert(memory is null);
    }
    body
    {
        free(&memory[0]);
        memory = null;
    }
}

static assert(isAllocator!CAllocator);

///
@nogc nothrow @safe unittest
{
    auto allocator = CAllocator();
    void[] array;
    assert(allocator.allocate(array, 5));
    assert(array.ptr !is null);
    assert(array.length == 5);

    assert(allocator.resize(array, 1));
    assert(array.ptr !is null);
    assert(array.length == 1);

    assert(allocator.resize(array, 10));
    assert(array.ptr !is null);
    assert(array.length == 10);

    allocator.free(array);
    assert(array.ptr is null);
    assert(array.length == 0);
}

