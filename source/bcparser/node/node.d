/**
Node structure.
*/
module bcparser.node;

import std.traits : isCopyable;

import bcparser.context : SourcePosition;

/**
Tag traits.
*/
enum isTag(T) = isCopyable!T && is(typeof(T.init) == T);

///
@nogc nothrow pure @safe unittest
{
    static assert(isTag!int);
    static assert(isTag!string);

    enum TestTag
    {
        TEST_1,
        TEST_2,
    }
    static assert(isTag!TestTag);

    struct NotTag
    {
        @disable this(ref return scope inout NotTag) inout;
        @disable this(this);
    }
    static assert(!isTag!NotTag);
}

/**
Node structure.

Params:
    T = tag type.
*/
struct Node(T) if (isTag!T)
{
    /// tag.
    T tag;

    /// begin position.
    SourcePosition begin;

    /// end position.
    SourcePosition end;

    /// node children.
    const(Node!T)[] children;
}

