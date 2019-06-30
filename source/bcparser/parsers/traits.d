/**
parsers traits module.
*/
module bcparser.parsers.traits;

import std.traits :
    Parameters,
    ParameterStorageClass,
    ParameterStorageClassTuple,
    ReturnType
;

import bcparser.context : isContext;

/**
Primitive parser function traits.
Params:
    P = parser function.
*/
enum bool isPrimitiveParser(alias P) =
    is(ReturnType!P == bool)
    && (Parameters!(P).length == 1)
    && is(typeof((ref Parameters!(P)[0] context) @nogc nothrow @safe
        {
            static assert(isContext!(Parameters!(P)[0]));
            static assert(ParameterStorageClassTuple!(P)[0]
                & ParameterStorageClass.ref_);

            bool result = P(context);
        }));

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

