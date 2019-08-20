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

version(unittest)
{
    void assertMatch(alias P)(string source) @nogc nothrow @safe
    {
        import bcparser : arraySource, CAllocator, parse;
        arraySource(source).parse!((scope ref context) {
            assert(P(context));
        })(CAllocator());
    }

    void assertMatchWithRest(alias P)(string source, string rest) @nogc nothrow @safe
    {
        import bcparser : arraySource, CAllocator, parse;
        arraySource(source).parse!((scope ref context) {
            assert(P(context));

            char c;
            foreach (expectedChar; rest)
            {
                assert(context.next(c) && c == expectedChar);
            }

            assert(!context.next(c));
        })(CAllocator());
    }

    void assertMatchAll(alias P)(string source) @nogc nothrow @safe
    {
        import bcparser : arraySource, CAllocator, parse;
        arraySource(source).parse!((scope ref context) {
            assert(P(context));
            
            char c;
            assert(!context.next(c));
        })(CAllocator());
    }

    void assertUnmatch(alias P)(string source) @nogc nothrow @safe
    {
        import bcparser : arraySource, CAllocator, parse;
        arraySource(source).parse!((scope ref context) {
            assert(!P(context));
        })(CAllocator());
    }
}

/// Parse a white space.
auto parseWhiteSpace(C)(scope ref C context) @nogc nothrow @safe
{
    return parseSet(context, "\x20\x09\x0a\x0d");
}

///
@nogc nothrow @safe unittest
{
    assertMatch!parseWhiteSpace(" ");
    assertMatch!parseWhiteSpace("\t");
    assertMatch!parseWhiteSpace("\r");
    assertMatch!parseWhiteSpace("\n");

    assertUnmatch!parseWhiteSpace("");
    assertUnmatch!parseWhiteSpace(".");
    assertUnmatch!parseWhiteSpace("a");
}

/// Parse white spaces.
auto parseWhiteSpaces(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseZeroOrMore!parseWhiteSpace;
}

///
@nogc nothrow @safe unittest
{
    assertMatch!parseWhiteSpaces("");
    assertMatch!parseWhiteSpaces(".");
    assertMatch!parseWhiteSpaces("a");
    assertMatch!parseWhiteSpaces("1");
    assertMatch!parseWhiteSpaces(" ");
    assertMatchAll!parseWhiteSpaces(" \t\r\n");
    assertMatchWithRest!parseWhiteSpaces(" \t\r\n.", ".");
    assertMatchWithRest!parseWhiteSpaces(". \t\r\n", ". \t\r\n");
}

/// Parse a structural characer with white spaces.
template parseStructuralCharacter(char CH)
{
    /// ditto.
    auto parseStructuralCharacter(C)(scope ref C context) @nogc nothrow @safe
    {
        return context.parseSequence!(
            parseWhiteSpaces,
            (scope ref c) => c.parseChar(CH),
            parseWhiteSpaces);
    }
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!(parseStructuralCharacter!'.')(".");
    assertMatchAll!(parseStructuralCharacter!'.')("\t\r\n .\t\r\n ");
    assertMatchWithRest!(parseStructuralCharacter!'.')("\t\r\n .\t\r\n .", ".");

    assertUnmatch!(parseStructuralCharacter!'.')("a");
    assertUnmatch!(parseStructuralCharacter!'.')("\t\r\n a\t\r\n ");
}
 
/// Parse begin-array.
auto parseBeginArray(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!'[';
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseBeginArray("[");
    assertMatchAll!parseBeginArray("\t\r\n [\t\r\n ");
    assertMatchWithRest!parseBeginArray("\t\r\n [\t\r\n [", "[");

    assertUnmatch!parseBeginArray("a");
    assertUnmatch!parseBeginArray("\t\r\n a\t\r\n ");
}
 
/// Parse end-array.
auto parseEndArray(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!']';
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseEndArray("]");
    assertMatchAll!parseEndArray("\t\r\n ]\t\r\n ");
    assertMatchWithRest!parseEndArray("\t\r\n ]\t\r\n ]", "]");

    assertUnmatch!parseEndArray("[");
    assertUnmatch!parseEndArray("\t\r\n [\t\r\n ");
}
 
/// Parse begin-object.
auto parseBeginObject(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!'{';
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseBeginObject("{");
    assertMatchAll!parseBeginObject("\t\r\n {\t\r\n ");
    assertMatchWithRest!parseBeginObject("\t\r\n {\t\r\n {", "{");

    assertUnmatch!parseBeginObject("}");
    assertUnmatch!parseBeginObject("\t\r\n }\t\r\n ");
}
 
/// Parse end-object.
auto parseEndObject(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!'}';
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseEndObject("}");
    assertMatchAll!parseEndObject("\t\r\n }\t\r\n ");
    assertMatchWithRest!parseEndObject("\t\r\n }\t\r\n }", "}");

    assertUnmatch!parseEndObject("{");
    assertUnmatch!parseEndObject("\t\r\n {\t\r\n ");
}
 
/// Parse name-separator.
auto parseNameSeparator(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!':';
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseNameSeparator(":");
    assertMatchAll!parseNameSeparator("\t\r\n :\t\r\n ");
    assertMatchWithRest!parseNameSeparator("\t\r\n :\t\r\n :", ":");

    assertUnmatch!parseNameSeparator(";");
    assertUnmatch!parseNameSeparator("\t\r\n ;\t\r\n ");
}
 
/// Parse value-separator.
auto parseValueSeparator(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseStructuralCharacter!',';
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseValueSeparator(",");
    assertMatchAll!parseValueSeparator("\t\r\n ,\t\r\n ");
    assertMatchWithRest!parseValueSeparator("\t\r\n ,\t\r\n ,", ",");

    assertUnmatch!parseValueSeparator(".");
    assertUnmatch!parseValueSeparator("\t\r\n .\t\r\n ");
}

/// Parse false.
auto parseFalse(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseString("false");
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseFalse("false");
    assertMatchWithRest!parseFalse("falsefalse", "false");

    assertUnmatch!parseFalse(" false");
    assertUnmatch!parseFalse("fals");
    assertUnmatch!parseFalse("");
}
 
/// Parse true.
auto parseTrue(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseString("true");
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseTrue("true");
    assertMatchWithRest!parseTrue("truetrue", "true");

    assertUnmatch!parseTrue(" true");
    assertUnmatch!parseTrue("tru");
    assertUnmatch!parseTrue("");
}
 
/// Parse null.
auto parseNull(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseString("null");
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseNull("null");
    assertMatchWithRest!parseNull("nullnull", "null");

    assertUnmatch!parseNull(" null");
    assertUnmatch!parseNull("nul");
    assertUnmatch!parseNull("");
}

/// Parse plus.
auto parsePlus(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseChar('+');
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parsePlus("+");
    assertMatchWithRest!parsePlus("++", "+");

    assertUnmatch!parsePlus(" +");
    assertUnmatch!parsePlus("-");
    assertUnmatch!parsePlus("");
}

 
/// Parse minus.
auto parseMinus(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseChar('-');
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseMinus("-");
    assertMatchWithRest!parseMinus("--", "-");

    assertUnmatch!parseMinus(" -");
    assertUnmatch!parseMinus("+");
    assertUnmatch!parseMinus("");
}

/// Parse zero.
auto parseZero(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseChar('0');
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseZero("0");
    assertMatchWithRest!parseZero("00", "0");

    assertUnmatch!parseZero(" 0");
    assertUnmatch!parseZero("1");
    assertUnmatch!parseZero("");
}

/// Parse decimal point.
auto parseDecimalPoint(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseChar('.');
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseDecimalPoint(".");
    assertMatchWithRest!parseDecimalPoint("..", ".");

    assertUnmatch!parseDecimalPoint(" .");
    assertUnmatch!parseDecimalPoint(",");
    assertUnmatch!parseDecimalPoint("");
}

/// Parse an exp character.
auto parseE(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseSet("eE");
}

///
@nogc nothrow @safe unittest
{
    assertMatchAll!parseE("E");
    assertMatchAll!parseE("e");
    assertMatchWithRest!parseE("ee", "e");
    assertMatchWithRest!parseE("EE", "E");

    assertUnmatch!parseE(" E");
    assertUnmatch!parseE(" e");
    assertUnmatch!parseE("f");
    assertUnmatch!parseE("");
}

/// Parse an digit.
auto parseDigit(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseRange('0', '9');
}

///
@nogc nothrow @safe unittest
{
    enum DIGITS = "0123456789";
    foreach (i; 0 .. DIGITS.length)
    {
        assertMatchAll!parseDigit(DIGITS[i .. i + 1]);
    }

    assertMatchWithRest!parseDigit("1234", "234");

    assertUnmatch!parseDigit("a");
    assertUnmatch!parseDigit("");
}

/// Parse an digit 1-9.
auto parseDigit19(C)(scope ref C context) @nogc nothrow @safe
{
    return context.parseRange('1', '9');
}

///
@nogc nothrow @safe unittest
{
    enum DIGITS = "123456789";
    foreach (i; 0 .. DIGITS.length)
    {
        assertMatchAll!parseDigit19(DIGITS[i .. i + 1]);
    }

    assertMatchWithRest!parseDigit19("1234", "234");

    assertUnmatch!parseDigit19("0");
    assertUnmatch!parseDigit19("a");
    assertUnmatch!parseDigit19("");
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
    static foreach(s; ["e+0123", "E+123", "e-9870", "E-9870"])
    {
        assertMatchAll!parseExp(s);
    }

    static foreach(s; ["e0123", "E123", "e9870", "E9870"])
    {
        assertMatchAll!parseExp(s);
    }

    static foreach(s; ["f1234", "1234", "+1234", "-1234"])
    {
        assertUnmatch!parseExp(s);
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
    assertMatchAll!parseFrac(".1234567890");
    assertMatchAll!parseFrac(".01234567890");
    assertMatchAll!parseFrac(".0000");
    assertMatchAll!parseFrac(".0");

    assertUnmatch!parseFrac("");
    assertUnmatch!parseFrac("1234");
    assertUnmatch!parseFrac("..1234");
    assertUnmatch!parseFrac(".");
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
    assertMatchAll!parseInt("0");
    assertMatchAll!parseInt("1");
    assertMatchAll!parseInt("123");
    assertMatchAll!parseInt("1234567890");

    assertUnmatch!parseInt("");
    assertUnmatch!parseInt("abc");
    assertUnmatch!parseInt(".1234");
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
    assertMatchAll!parseNumber("0");
    assertMatchAll!parseNumber("-0");
    assertMatchAll!parseNumber("1");
    assertMatchAll!parseNumber("-1");
    assertMatchAll!parseNumber("123");
    assertMatchAll!parseNumber("-123");
    assertMatchAll!parseNumber("1234567890");
    assertMatchAll!parseNumber("-1234567890");

    assertMatchAll!parseNumber("1234567890.0");
    assertMatchAll!parseNumber("1234567890.01234");
    assertMatchAll!parseNumber("1234567890.91234567890");

    assertMatchAll!parseNumber("-1234567890.0");
    assertMatchAll!parseNumber("-1234567890.01234");
    assertMatchAll!parseNumber("-1234567890.91234567890");

    assertMatchAll!parseNumber("1234567890e+01234");
    assertMatchAll!parseNumber("1234567890e-01234");
    assertMatchAll!parseNumber("1234567890E+01234");
    assertMatchAll!parseNumber("1234567890E-01234");

    assertMatchAll!parseNumber("-1234567890e+01234");
    assertMatchAll!parseNumber("-1234567890e-01234");
    assertMatchAll!parseNumber("-1234567890E+01234");
    assertMatchAll!parseNumber("-1234567890E-01234");

    assertMatchAll!parseNumber("123.1234567890e+01234");
    assertMatchAll!parseNumber("123.1234567890e-01234");
    assertMatchAll!parseNumber("123.1234567890E+01234");
    assertMatchAll!parseNumber("123.1234567890E-01234");

    assertMatchAll!parseNumber("-123.1234567890e+01234");
    assertMatchAll!parseNumber("-123.1234567890e-01234");
    assertMatchAll!parseNumber("-123.1234567890E+01234");
    assertMatchAll!parseNumber("-123.1234567890E-01234");

    assertUnmatch!parseNumber("");
    assertUnmatch!parseNumber("abc");
    assertUnmatch!parseNumber(".1234");
    assertUnmatch!parseNumber("+1234");
}

