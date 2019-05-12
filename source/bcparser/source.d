module bcparser.source;

import std.traits : isCopyable, ReturnType;

/**
Source operation result.
*/
enum SourceResult: bool
{
    failed = false,
    success = true,
}

/**
Source interface.
*/
enum bool isSource(S) =
    is(typeof(S.init) == S)
    && isCopyable!S
    && is(ReturnType!((S s) @nogc nothrow pure @safe => s.empty) == bool)
    && is(typeof((return ref S s) @nogc nothrow pure @safe  => s.front))
    && !is(ReturnType!((S s) @nogc nothrow pure @safe => s.front) == void)
    && is(typeof((S s) @nogc nothrow pure @safe => s.popFront))
    && is(typeof((S s) @nogc nothrow pure @safe => s.begin))
    && is(ReturnType!((S s) @nogc nothrow pure @safe => s.begin) == SourceResult)
    && is(typeof((S s) @nogc nothrow pure @safe => s.accept))
    && is(typeof((S s) @nogc nothrow pure @safe => s.backtrack))
    && is(ReturnType!((S s) @nogc nothrow pure @safe => s.backtrack) == SourceResult);

///
@nogc nothrow pure @safe unittest
{
    struct Source
    {
        @property bool empty() @nogc nothrow pure @safe;
        @property int front() @nogc nothrow pure @safe;
        void popFront() @nogc nothrow pure @safe;
        SourceResult begin() @nogc nothrow pure @safe;
        void accept() @nogc nothrow pure @safe;
        SourceResult backtrack() @nogc nothrow pure @safe;
    }
    static assert(isSource!Source);

    struct HaveNotEmpty 
    {
        //@property bool empty() @nogc nothrow pure @safe;
        @property int front() @nogc nothrow pure @safe;
        void popFront() @nogc nothrow pure @safe;
        SourceResult begin() @nogc nothrow pure @safe;
        void accept() @nogc nothrow pure @safe;
        SourceResult backtrack() @nogc nothrow pure @safe;
    }
    static assert(!isSource!HaveNotEmpty);

    struct WrongResultType
    {
        @property bool empty() @nogc nothrow pure @safe;
        @property int front() @nogc nothrow pure @safe;
        void popFront() @nogc nothrow pure @safe;
        SourceResult begin() @nogc nothrow pure @safe;
        void accept() @nogc nothrow pure @safe;
        /* SourceResult */ bool backtrack() @nogc nothrow pure @safe;
    }
    static assert(!isSource!WrongResultType);

    struct WrongGC 
    {
        @property bool empty() @nogc nothrow pure @safe;
        @property int front() /* @nogc */ nothrow pure @safe;
        void popFront() @nogc nothrow pure @safe;
        SourceResult begin() @nogc nothrow pure @safe;
        void accept() @nogc nothrow pure @safe;
        SourceResult backtrack() @nogc nothrow pure @safe;
    }
    static assert(!isSource!WrongGC);
}

