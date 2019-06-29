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
    bool allocate(scope return out void[] memory, size_t n) @nogc nothrow @trusted
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
    bool resize(scope return ref void[] memory, size_t n) @nogc nothrow @trusted
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
    void free(scope return ref void[] memory) @nogc nothrow @trusted
    out
    {
        assert(memory is null);
    }
    body
    {
        if (memory.length > 0)
        {
            free(&memory[0]);
        }
        memory = null;
    }
}

static assert(isAllocator!CAllocator);

///
@nogc nothrow @trusted unittest
{
    auto allocator = CAllocator();
    void[] array;
    assert(allocator.allocate(array, 5));
    assert(array.ptr !is null);
    assert(array.length == 5);

    // set values.
    foreach (i, ref v; cast(ubyte[]) array)
    {
        v = cast(ubyte) i;
    }

    // resize memory.
    assert(allocator.resize(array, 3));
    assert(array.ptr !is null);
    assert(array.length == 3);

    // keep old memory values.
    foreach (i, v; cast(ubyte[]) array)
    {
        assert(v == i);
    }

    assert(allocator.resize(array, 10));
    assert(array.ptr !is null);
    assert(array.length == 10);

    // keep old memory values.
    foreach (i, v; (cast(ubyte[]) array)[0 .. 3])
    {
        assert(v == i);
    }

    allocator.free(array);
    assert(array.ptr is null);
    assert(array.length == 0);
}

