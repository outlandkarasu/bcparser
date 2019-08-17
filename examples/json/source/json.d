/**
bcparser JSON parser example.

https://tools.ietf.org/html/rfc8259
*/
module bcparser.examples.json; 
import bcparser :
    parseChar,
    parseRange,
    parseString,
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
auto parseWhiteSpace(C)(scope ref C context) @nogc nothrow @safe
{
    return parseSet(context, "\x20\x09\x0a\x0d");
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n.").parse!((scope ref context) {
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
auto parseWhiteSpaces(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseZeroOrMore!parseWhiteSpace;
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n.").parse!((scope ref context) {
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
private auto parseStructuralCharacter(char CH, C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseSequence!(
        parseWhiteSpaces,
        (scope ref c) => c.parseChar(CH),
        parseWhiteSpaces);
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n.\t\r\n a").parse!((scope ref context) {
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
auto parseBeginArray(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!'[';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n[\t\r\n ").parse!((scope ref context) {
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
auto parseEndArray(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!']';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n]\t\r\n ").parse!((scope ref context) {
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
auto parseBeginObject(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!'{';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n{\t\r\n ").parse!((scope ref context) {
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
auto parseEndObject(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!'}';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n}\t\r\n ").parse!((scope ref context) {
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
auto parseNameSeparator(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!':';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n:\t\r\n ").parse!((scope ref context) {
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
auto parseValueSeparator(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!',';
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(" \t\r\n,\t\r\n ").parse!((scope ref context) {
        assert(context.parseValueSeparator);
        assert(!context.parseValueSeparator);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}

/**
Parse false.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseFalse(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseString("false");
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("false").parse!((scope ref context) {
        assert(context.parseFalse);
        assert(!context.parseFalse);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}
 
/**
Parse true.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseTrue(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseString("true");
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("true").parse!((scope ref context) {
        assert(context.parseTrue);
        assert(!context.parseTrue);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}
 
/**
Parse null.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseNull(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseString("null");
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("null").parse!((scope ref context) {
        assert(context.parseNull);
        assert(!context.parseNull);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}

/**
Parse plus.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parsePlus(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseChar('+');
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("+").parse!((scope ref context) {
        assert(context.parsePlus);
        assert(!context.parsePlus);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}

 
/**
Parse minus.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseMinus(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseChar('-');
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("-").parse!((scope ref context) {
        assert(context.parseMinus);
        assert(!context.parseMinus);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}

/**
Parse zero.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseZero(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseChar('0');
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("0").parse!((scope ref context) {
        assert(context.parseZero);
        assert(!context.parseZero);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}

/**
Parse decimal point.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseDecimalPoint(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseChar('.');
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(".").parse!((scope ref context) {
        assert(context.parseDecimalPoint);
        assert(!context.parseDecimalPoint);

        char c;
        assert(!context.next(c));
    })(CAllocator());
}

/**
Parse an exp character.

Params:
    C = context type.
    context = parsing context.
Returns:
    parsing result.
*/
auto parseE(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseSet("eE");
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("eEf").parse!((scope ref context) {
        assert(context.parseE);
        assert(context.parseE);
        assert(!context.parseE);

        char c;
        assert(context.next(c) && c == 'f');
    })(CAllocator());
}

/**
Parse an digit.
*/
auto parseDigit(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseRange('0', '9');
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("0123456789.").parse!((scope ref context) {
        assert(context.parseDigit);
        assert(context.parseDigit);
        assert(context.parseDigit);
        assert(context.parseDigit);
        assert(context.parseDigit);
        assert(context.parseDigit);
        assert(context.parseDigit);
        assert(context.parseDigit);
        assert(context.parseDigit);
        assert(context.parseDigit);
        assert(!context.parseDigit);

        char c;
        assert(context.next(c) && c == '.');
    })(CAllocator());
}

