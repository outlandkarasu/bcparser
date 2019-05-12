module bcparser.allocator;

import std.traits : isCopyable, ReturnType;

/**
Allocator interface.
*/
enum bool isAllocator(A) =
    is(typeof(A.init) == A)
    && isCopyable!A
    && is(ReturnType!((scope ref A a) @nogc nothrow pure @safe
        => a.allocate(cast(size_t) 1)) == void[])
    && is(typeof((scope ref A a, scope void[] b) @nogc nothrow pure @safe => a.free(b)));

///
@nogc nothrow pure @safe unittest
{
    struct Allocator
    {
        void[] allocate(size_t n) @nogc nothrow pure @safe;
        void free(scope void[] b) @nogc nothrow pure @safe;
    }
    static assert(isAllocator!Allocator);

    struct HaveNotFree
    {
        void[] allocate(size_t n) @nogc nothrow pure @safe;
        //void free(scope void[] b) @nogc nothrow pure @safe;
    }
    static assert(!isAllocator!HaveNotFree);

    struct WrongGC
    {
        void[] allocate(size_t n) /* @nogc */ nothrow pure @safe;
        void free(scope void[] b) @nogc nothrow pure @safe;
    }
    static assert(!isAllocator!WrongGC);
}
