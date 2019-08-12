/**
bcparser JSON parser example.
*/
module bcparser.examples.json;

import bcparser :
    parseChar,
    parseSequence,
    parseSet,
    parseZeroOrMore
;

/**
Parse white space.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseWhiteSpace(C)(ref C context) @nogc nothrow @safe
{
    return parseSet(context, "\x20\x09\x0a\x0d");
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n.").parse!((ref context) {
        assert(parseWhiteSpace(context));
        assert(parseWhiteSpace(context));
        assert(parseWhiteSpace(context));
        assert(parseWhiteSpace(context));
        assert(!parseWhiteSpace(context));

        char c;
        assert(context.next(c) && c == '.');
    })(CAllocator());
}

/**
Parse white spaces.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseWhiteSpaces(C)(ref C context) @nogc nothrow @safe
{
    return parseZeroOrMore!(parseWhiteSpace)(context);
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n.").parse!((ref context) {
        assert(parseWhiteSpaces(context));

        // any space not found but succeeded.
        assert(parseWhiteSpaces(context));

        char c;
        assert(context.next(c) && c == '.');
    })(CAllocator());
}

/**
Parse a structural characer with white spaces.

Params:
    CH = character literal.
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
private auto parseStructuralCharacter(char CH, C)(ref C context) @nogc nothrow @safe
{
    return context.parseSequence!(
        parseWhiteSpaces,
        (ref c) => c.parseChar(CH),
        parseWhiteSpaces);
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n.\t\r\n a").parse!((ref context) {
        assert(context.parseStructuralCharacter!'.');
        assert(context.parseStructuralCharacter!'a');

        char c;
        assert(!context.next(c));
    })(CAllocator());
}
 
/**
Parse begin-array.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseBeginArray(C)(ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!'[';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n[\t\r\n ").parse!((ref context) {
        assert(context.parseBeginArray);
        assert(!context.parseBeginArray);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}
 
/**
Parse end-array.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseEndArray(C)(ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!']';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n]\t\r\n ").parse!((ref context) {
        assert(context.parseEndArray);
        assert(!context.parseEndArray);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}
 
/**
Parse begin-object.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseBeginObject(C)(ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!'{';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n{\t\r\n ").parse!((ref context) {
        assert(context.parseBeginObject);
        assert(!context.parseBeginObject);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}
 
/**
Parse end-object.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseEndObject(C)(ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!'}';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n}\t\r\n ").parse!((ref context) {
        assert(context.parseEndObject);
        assert(!context.parseEndObject);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}
 
/**
Parse name-separator.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseNameSeparator(C)(ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!':';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n:\t\r\n ").parse!((ref context) {
        assert(context.parseNameSeparator);
        assert(!context.parseNameSeparator);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}
 
/**
Parse value-separator.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseValueSeparator(C)(ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!',';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n,\t\r\n ").parse!((ref context) {
        assert(context.parseValueSeparator);
        assert(!context.parseValueSeparator);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}
 
