/**
parsers traits module.
*/
module bcparser.parsers.traits;

import std.traits :
    hasFunctionAttributes,
    isCallable,
    Parameters,
    ParameterStorageClass,
    ParameterStorageClassTuple,
    ReturnType
;

import bcparser.context : isContext;

/**
Primitive parser traits.

Params:
    P = parser.
*/
enum bool isPrimitiveParser(alias P) = isPrimitiveParserFunction!(typeof(P));

///
@nogc nothrow pure @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : ArraySource;
    import bcparser.context : Context;
    alias Ctx = Context!(ArraySource!char, CAllocator);

    // for lambda test.
    static assert(isPrimitiveParser!((ref Ctx s) => true));
    static assert(!isPrimitiveParser!((ref Ctx s, char c) => true));
    static assert(!isPrimitiveParser!(() => true));
    static assert(!isPrimitiveParser!((ref Ctx s) => 5));
    static assert(!isPrimitiveParser!((ref Ctx s) @system => true));
    static assert(!isPrimitiveParser!((ref Ctx s) => new bool(false)));
    static assert(!isPrimitiveParser!((ref Ctx s) { throw new Exception("error"); }));

    // for functions test.
    bool parser(ref Ctx s) { return true; }
    static assert(isPrimitiveParser!parser);

    bool notParser(ref Ctx s, char c) { return true; }
    static assert(!isPrimitiveParser!notParser);
}

/**
Primitive parser traits.
Params:
    P = parser template.
    C = context type.
*/
enum bool isPrimitiveParser(alias P, C) =
    __traits(isTemplate, P)
    && is(typeof(()
        {
            static assert(isPrimitiveParser!(P!C));
        }));

///
@nogc nothrow pure @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : ArraySource;
    import bcparser.context : Context;
    alias Ctx = Context!(ArraySource!char, CAllocator);

    // for lambda test.
    static assert(isPrimitiveParser!((ref s) => true, Ctx));
    static assert(!isPrimitiveParser!((ref s, char c) => true, Ctx));
    static assert(!isPrimitiveParser!(() => true, Ctx));
    static assert(!isPrimitiveParser!((ref s) => 5, Ctx));
    static assert(!isPrimitiveParser!((ref s) @system => true, Ctx));
    static assert(!isPrimitiveParser!((ref s) => new bool(false), Ctx));
    static assert(!isPrimitiveParser!((ref s) { throw new Exception("error"); }, Ctx));
}

/**
Primitive parser function traits.

Params:
    P = parser function.
*/
enum bool isPrimitiveParserFunction(P) =
    isCallable!P
    && is(ReturnType!P == bool)
    && (Parameters!(P).length == 1)
    && hasFunctionAttributes!(P, "@nogc", "nothrow", "@safe")
    && is(typeof((ref Parameters!(P)[0] context) @nogc nothrow @safe
        {
            static assert(isContext!(Parameters!(P)[0]));
            static assert(ParameterStorageClassTuple!(P)[0] & ParameterStorageClass.ref_);
        }));

///
@nogc nothrow pure @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : ArraySource;
    import bcparser.context : Context;
    alias Ctx = Context!(ArraySource!char, CAllocator);

    // lambda tests.
    static assert(isPrimitiveParserFunction!(typeof((ref Ctx s) => true)), typeof((ref Ctx s) => true).stringof);
    static assert(!isPrimitiveParserFunction!(typeof((ref Ctx s, char c) => true)));
    static assert(!isPrimitiveParserFunction!(typeof(() => true)));
    static assert(!isPrimitiveParserFunction!(typeof((ref Ctx s) => 5)));
    static assert(!isPrimitiveParserFunction!(typeof((ref Ctx s) @system => true)));
    static assert(!isPrimitiveParserFunction!(typeof((ref Ctx s) => new bool(false))));
    static assert(!isPrimitiveParserFunction!(typeof((ref Ctx s) { throw new Exception("error"); })));

    // functions tests.
    bool parser(ref Ctx s) @nogc nothrow pure @safe { return true; }
    static assert(isPrimitiveParserFunction!(typeof(parser)), typeof(parser).stringof);

    bool notParser(ref Ctx s, char c) { return true; }
    static assert(!isPrimitiveParserFunction!(typeof(notParser)));

    static assert(__traits(isTemplate, (ref s) => true));
}

