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

