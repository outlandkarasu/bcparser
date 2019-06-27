module bcparser.memory.allocator;

import std.traits : isCopyable, ReturnType;

/**
Allocator interface.
*/
enum bool isAllocator(A) =
    is(typeof(A.init) == A)
    && isCopyable!A
    && is(ReturnType!((scope ref A a, scope ref void[] b) @nogc nothrow @safe
        => a.allocate(b, cast(size_t) 1)) == bool)
    && is(ReturnType!((scope ref A a, scope ref void[] b) @nogc nothrow @safe
        => a.resize(b, cast(size_t) 5)) == bool)
    && is(typeof((scope ref A a, scope ref void[] b) @nogc nothrow @safe => a.free(b)));

///
@nogc nothrow @safe unittest
{
    struct Allocator
    {
        bool allocate(scope return out void[] b, size_t n) @nogc nothrow @safe;
        bool resize(scope return ref void[] b, size_t n) @nogc nothrow @safe;
        void free(scope return ref void[] b) @nogc nothrow @safe;
    }
    static assert(isAllocator!Allocator);

    struct HaveNotFree
    {
        bool allocate(scope return out void[] b, size_t n) @nogc nothrow @safe;
        bool resize(scope return ref void[] b, size_t n) @nogc nothrow @safe;
        //void free(scope ref void[] b) @nogc nothrow @safe;
    }
    static assert(!isAllocator!HaveNotFree);

    struct WrongGC
    {
        bool allocate(scope return out void[] b, size_t n) /* @nogc */ nothrow @safe;
        bool resize(scope return ref void[] b, size_t n) @nogc nothrow @safe;
        void free(scope return ref void[] b) @nogc nothrow @safe;
    }
    static assert(!isAllocator!WrongGC);
}

/**
release elements array.

Params:
    A = allocator type.
    E = element type.
    allocator = memory allocator.
    array = dest array.
*/
void release(A, E)(
    scope return ref A allocator,
    scope return ref E[] array) @nogc nothrow @safe
{
    void[] memory = array;
    allocator.free(memory);
    array = null;
}

///
@nogc nothrow @trusted unittest
{
    import bcparser.memory : CAllocator;

    auto allocator = CAllocator();

    // allocate memory.
    void[] memory;
    allocator.allocate(memory, 16);
    auto array = cast(char[]) memory;
    assert(array.length == 16);

    // release memory.
    allocator.release(array);
    assert(array.length == 0);
}

/**
add an element.

Params:
    A = allocator type.
    E = element type.
    allocator = memory allocator.
    array = dest array.
    element = add element.
Returns:
    true if succeeded.
*/
bool add(A, E)(
    scope return ref A allocator,
    scope return ref E[] array,
    auto scope return ref E element) @nogc nothrow @trusted
{
    void[] memory = array;
    bool success;
    if (memory.length > 0)
    {
        success = allocator.resize(memory, memory.length + E.sizeof);
    }
    else
    {
        success = allocator.allocate(memory, E.sizeof);
    }

    if (!success)
    {
        return false;
    }

    array = cast(E[]) memory;
    array[$ - 1] = element;
    return true;
}

///
@nogc nothrow @safe unittest
{
    import bcparser.memory : CAllocator;

    char[] array;
    auto allocator = CAllocator();
    allocator.add(array, 'a');
    scope(exit) allocator.release(array);

    assert(array.length == 1);
    assert(array[0] == 'a');

    allocator.add(array, 'b');
    allocator.add(array, 'c');
    assert(array.length == 3);
    assert(array == "abc");
}

