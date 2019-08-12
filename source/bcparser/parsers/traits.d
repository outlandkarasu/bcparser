/**
parsers traits module.
*/
module bcparser.parsers.traits;

import std.traits :
    hasFunctionAttributes,
    isCallable,
    isType,
    Parameters,
    ParameterStorageClass,
    ParameterStorageClassTuple,
    ReturnType
;

import bcparser.context : isContext;
import bcparser.result : ParsingResult;

/**
Primitive parser function traits.

Params:
    P = parser function.
*/
enum bool isPrimitiveParserFunction(P) =
    isCallable!P
    && is(typeof((ref Parameters!(P)[0] context) @nogc nothrow @safe
        {
            static assert(is(ReturnType!P : ParsingResult));
            static assert(Parameters!(P).length == 1);
            static assert(hasFunctionAttributes!(P, "@nogc", "nothrow", "@safe"));
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
    static assert(isPrimitiveParserFunction!(typeof((ref Ctx s) => ParsingResult.match)));
    static assert(!isPrimitiveParserFunction!(typeof((ref Ctx s, char c) => ParsingResult.match)));
    static assert(!isPrimitiveParserFunction!(typeof(() => ParsingResult.match)));
    static assert(!isPrimitiveParserFunction!(typeof((ref Ctx s) => true)));
    static assert(!isPrimitiveParserFunction!(typeof((ref Ctx s) @system => ParsingResult.match)));
    static assert(!isPrimitiveParserFunction!(typeof((ref Ctx s) => ParsingResult.createError(new string(5)))));

    version (D_Exceptions)
    {
        static assert(!isPrimitiveParserFunction!(typeof((ref Ctx s) { throw new Exception("error"); })));
    }

    // functions tests.
    ParsingResult parser(ref Ctx s) @nogc nothrow pure @safe { return ParsingResult.match; }
    static assert(isPrimitiveParserFunction!(typeof(parser)));

    ParsingResult notParser(ref Ctx s, char c) { return ParsingResult.match; }
    static assert(!isPrimitiveParserFunction!(typeof(notParser)));
}

/**
Primitive parser traits.

Params:
    P = parser function.
    C = context type.
Returns:
    true if P is primitive parser.
*/
enum bool isPrimitiveParser(alias P, C) =
    (__traits(isTemplate, P) && is(typeof({ static assert(isPrimitiveParserFunction!(typeof(P!C))); })))
    || isPrimitiveParserFunction!(typeof(P));

/// ditto
enum bool isPrimitiveParser(P, C) = isPrimitiveParserFunction!P;

///
@nogc nothrow pure @safe unittest
{
    import bcparser.memory : CAllocator;
    import bcparser.source : ArraySource;
    import bcparser.context : Context;
    alias Ctx = Context!(ArraySource!char, CAllocator);

    // lambda tests.
    static assert(isPrimitiveParser!(typeof((ref Ctx s) => ParsingResult.match), Ctx));
    static assert(isPrimitiveParser!((ref s) => ParsingResult.match, Ctx));
    static assert(isPrimitiveParser!((ref Ctx s) => ParsingResult.match, Ctx));

    // functions tests.
    ParsingResult parser(ref Ctx s) @nogc nothrow pure @safe { return ParsingResult.match; }
    static assert(isPrimitiveParser!(parser, Ctx));
    static assert(isPrimitiveParser!(typeof(parser), Ctx));

    ParsingResult notParser(ref Ctx s, char c) { return ParsingResult.match; }
    static assert(!isPrimitiveParser!(notParser, Ctx));
    static assert(!isPrimitiveParser!(typeof(notParser), Ctx));
}

