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

import bcparser.source : isSource;

/**
Primitive parser function traits.
Params:
    P = parser function.
*/
enum bool isPrimitiveParser(alias P) =
    is(ReturnType!P == bool)
    && (Parameters!(P).length == 1)
    && is(typeof((ref Parameters!(P)[0] s) @nogc nothrow @safe
        {
            static assert(isSource!(Parameters!(P)[0]));
            static assert(ParameterStorageClassTuple!(P)[0]
                & ParameterStorageClass.ref_);

            bool result = P(s);
        }));

///
@nogc nothrow pure @safe unittest
{
    import bcparser.source : ArraySource;
    alias Source = ArraySource!char;

    // for lambda test.
    static assert(isPrimitiveParser!((ref Source s) => true));
    static assert(!isPrimitiveParser!(() => true));
    static assert(!isPrimitiveParser!((Source s) => true));
    static assert(!isPrimitiveParser!((out Source s) => true));
    static assert(!isPrimitiveParser!((ref Source s) => 5));
    static assert(!isPrimitiveParser!((ref Source s) @system => true));
    static assert(!isPrimitiveParser!((ref Source s) => new bool(false)));
    static assert(!isPrimitiveParser!((ref Source s) { throw new Exception("error"); }));

    // for functions test.
    bool parser(ref Source s) { return true; }
    static assert(isPrimitiveParser!parser);

    bool notParser(Source s) { return true; }
    static assert(!isPrimitiveParser!notParser);
}

