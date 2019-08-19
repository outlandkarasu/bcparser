/**
bcparser JSON parser example.

https://tools.ietf.org/html/rfc8259
*/
module bcparser.examples.json; 
import bcparser :
    parseChar,
    parseChoice,
    parseOption,
    parseOneOrMore,
    parseRange,
    parseString,
    parseSequence,
    parseSet,
    parseZeroOrMore
;

/// Parse a white space.
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

/// Parse white spaces.
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

/// Parse a structural characer with white spaces.
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
 
/// Parse begin-array.
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
 
/// Parse end-array.
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
 
/// Parse begin-object.
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
 
/// Parse end-object.
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
 
/// Parse name-separator.
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
 
/// Parse value-separator.
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

/// Parse false.
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
 
/// Parse true.
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
 
/// Parse null.
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

/// Parse plus.
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

 
/// Parse minus.
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

/// Parse zero.
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

/// Parse decimal point.
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

/// Parse an exp character.
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

/// Parse an digit.
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

/// Parse an digit 1-9.
auto parseDigit19(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseRange('1', '9');
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("1234567890").parse!((scope ref context) {
        assert(context.parseDigit19);
        assert(context.parseDigit19);
        assert(context.parseDigit19);
        assert(context.parseDigit19);
        assert(context.parseDigit19);
        assert(context.parseDigit19);
        assert(context.parseDigit19);
        assert(context.parseDigit19);
        assert(context.parseDigit19);
        assert(!context.parseDigit19);

        char c;
        assert(context.next(c) && c == '0');
    })(CAllocator());
}

/// parse exp.
auto parseExp(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseSequence!(
        parseE, 
        parseOption!(parseChoice!(parseMinus, parsePlus)),
        parseOneOrMore!parseDigit);
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("e+0123,E+123,e-9870,E-9870").parse!((scope ref context) {
        char c;
        assert(context.parseExp);
        assert(context.next(c) && c == ',');
        assert(context.parseExp);
        assert(context.next(c) && c == ',');
        assert(context.parseExp);
        assert(context.next(c) && c == ',');
        assert(context.parseExp);
        assert(!context.parseExp);
        assert(!context.next(c));
    })(CAllocator());

    arraySource("e0123,E123,e9870,E9870").parse!((scope ref context) {
        char c;
        assert(context.parseExp);
        assert(context.next(c) && c == ',');
        assert(context.parseExp);
        assert(context.next(c) && c == ',');
        assert(context.parseExp);
        assert(context.next(c) && c == ',');
        assert(context.parseExp);
        assert(!context.parseExp);
        assert(!context.next(c));
    })(CAllocator());

    static foreach(s; ["f1234", "1234", "+1234", "-1234"])
    {
        arraySource(s).parse!((scope ref context) {
            assert(!context.parseExp);
        })(CAllocator());
    }
}

/// parse frac.
auto parseFrac(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseSequence!(
        parseDecimalPoint, 
        parseOneOrMore!parseDigit);
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource(".1234567890,.0123456789,.0000,.0").parse!((scope ref context) {
        char c;
        assert(context.parseFrac);
        assert(context.next(c) && c == ',');
        assert(context.parseFrac);
        assert(context.next(c) && c == ',');
        assert(context.parseFrac);
        assert(context.next(c) && c == ',');
        assert(context.parseFrac);
        assert(!context.parseFrac);
        assert(!context.next(c));
    })(CAllocator());

    static foreach(s; ["", "1234", "..1234", "."])
    {
        arraySource(s).parse!((scope ref context) {
            assert(!context.parseFrac);
        })(CAllocator());
    }
}

/// parse an int.
auto parseInt(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseChoice!(
        parseZero,
        parseSequence!(parseDigit19, parseZeroOrMore!parseDigit));
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("0,1,123,1234567890").parse!((scope ref context) {
        char c;
        assert(context.parseInt);
        assert(context.next(c) && c == ',');
        assert(context.parseInt);
        assert(context.next(c) && c == ',');
        assert(context.parseInt);
        assert(context.next(c) && c == ',');
        assert(context.parseInt);
        assert(!context.parseInt);
        assert(!context.next(c));
    })(CAllocator());

    static foreach(s; ["", "abc", ".1234"])
    {
        arraySource(s).parse!((scope ref context) {
            assert(!context.parseInt);
        })(CAllocator());
    }
}

/// parse a number.
auto parseNumber(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseSequence!(
        parseOption!parseMinus,
        parseInt,
        parseOption!parseFrac,
        parseOption!parseExp);
}

///
@nogc nothrow @safe unittest
{
    import bcparser : arraySource, CAllocator, parse;

    arraySource("0,1,123,1234567890").parse!((scope ref context) {
        char c;
        assert(context.parseNumber);
        assert(context.next(c) && c == ',');
        assert(context.parseNumber);
        assert(context.next(c) && c == ',');
        assert(context.parseNumber);
        assert(context.next(c) && c == ',');
        assert(context.parseNumber);
        assert(!context.parseNumber);
        assert(!context.next(c));
    })(CAllocator());

    static foreach(s; ["", "abc", ".1234"])
    {
        arraySource(s).parse!((scope ref context) {
            assert(!context.parseNumber);
        })(CAllocator());
    }
}

