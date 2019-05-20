module bcparser.source;

import std.traits :
    isCopyable,
    Parameters,
    ParameterStorageClass,
    ParameterStorageClassTuple,
    ReturnType
;

/**
Source interface.
*/
enum bool isSource(S) =
    is(typeof(S.init) == S)
    && is(typeof((return ref S s) @nogc nothrow pure @safe
        {
            // get next element.
            alias E = Parameters!(s.next)[0];
            E c;
            bool result = s.next(c);

            // next function has an element out parameter.
            static assert(ParameterStorageClassTuple!(typeof(s.next))[0]
                & ParameterStorageClass.out_);

            // get current position.
            auto position = s.position;
            static assert(isCopyable!(typeof(position)));

            // move to saved position.
            s.moveTo(position);
        }));

///
@nogc nothrow pure @safe unittest
{
    struct Source
    {
        bool next(out int e) @nogc nothrow pure @safe;
        @property size_t position() const @nogc nothrow pure @safe;
        void moveTo(size_t position) @nogc nothrow pure @safe;
    }
    static assert(isSource!Source);

    struct NotSource
    {
        //bool next(out int e) @nogc nothrow pure @safe;
        @property size_t position() const @nogc nothrow pure @safe;
        void moveTo(size_t position) @nogc nothrow pure @safe;
    }
    static assert(!isSource!NotSource);
}

/**
get source element type.
*/
template SourceElementType(S)
if(isSource!S)
{
    alias SourceElementType
        = ReturnType!((ref S s) => Parameters!(s.next)[0].init);
}

///
@nogc nothrow pure @safe unittest
{
    struct Source
    {
        bool next(out int e) @nogc nothrow pure @safe;
        @property size_t position() const @nogc nothrow pure @safe;
        void moveTo(size_t position) @nogc nothrow pure @safe;
    }
    static assert(is(SourceElementType!Source == int));
}

/**
get source position type.
*/
template SourcePositionType(S)
if(isSource!S)
{
    alias SourcePositionType = ReturnType!((ref S s) => s.position);
}

///
@nogc nothrow pure @safe unittest
{
    struct Source
    {
        bool next(out int e) @nogc nothrow pure @safe;
        @property size_t position() const @nogc nothrow pure @safe;
        void moveTo(size_t position) @nogc nothrow pure @safe;
    }
    static assert(is(SourcePositionType!Source == size_t));
}

