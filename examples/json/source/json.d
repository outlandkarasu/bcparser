/**
bcparser JSON parser example.

https://tools.ietf.org/html/rfc8259
*/
module bcparser.examples.json; 

import bcparser :
    ParsingResult,
    parseChar,
    parseChoice,
    parseEvent,
    parseOption,
    parseOneOrMore,
    parseRange,
    parseString,
    parseSequence,
    parseSet,
    parseZeroOrMore
;

@nogc @safe nothrow:

version(unittest)
{
    void assertMatch(alias P)(scope const(char)[] source) @nogc nothrow @safe
    {
        import bcparser : arraySource, CAllocator, parse;
        arraySource(source).parse!((scope ref context) {
            assert(P(context));
        })(CAllocator());
    }

    void assertMatchWithRest(alias P)(
            scope const(char)[] source,
            scope const(char)[] rest) @nogc nothrow @safe
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

    void assertMatchAll(alias P)(scope const(char)[] source) @nogc nothrow @safe
    {
        import bcparser : arraySource, CAllocator, parse;
        arraySource(source).parse!((scope ref context) {
            assert(P(context));
            
            char c;
            assert(!context.next(c));
        })(CAllocator());
    }

    void assertUnmatch(alias P)(scope const(char)[] source) @nogc nothrow @safe
    {
        import bcparser : arraySource, CAllocator, parse;
        arraySource(source).parse!((scope ref context) {
            assert(!P(context));
        })(CAllocator());
    }
}

/// JSON node type.
enum JsonNode
{
    array = "array",
    falseValue = "false",
    member = "member",
    nullValue = "null",
    numberValue = "number",
    object = "object",
    stringValue = "string",
    trueValue = "true",
}

/// Parse a white space.
ParsingResult parseWhiteSpace(C)(scope ref C context)
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
ParsingResult parseWhiteSpaces(C)(scope ref C context)
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
    ParsingResult parseStructuralCharacter(C)(scope ref C context)
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
ParsingResult parseBeginArray(C)(scope ref C context)
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
ParsingResult parseEndArray(C)(scope ref C context)
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
ParsingResult parseBeginObject(C)(scope ref C context)
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
ParsingResult parseEndObject(C)(scope ref C context)
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
ParsingResult parseNameSeparator(C)(scope ref C context)
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
ParsingResult parseValueSeparator(C)(scope ref C context)
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
ParsingResult parseFalse(C)(scope ref C context)
{
    return context.parseEvent!(
            JsonNode.falseValue,
            (scope ref c) => c.parseString("false"));
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
ParsingResult parseTrue(C)(scope ref C context)
{
    return context.parseEvent!(
            JsonNode.trueValue,
            (scope ref c) => c.parseString("true"));
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
ParsingResult parseNull(C)(scope ref C context)
{
    return context.parseEvent!(
            JsonNode.nullValue,
            (scope ref c) => c.parseString("null"));
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
ParsingResult parsePlus(C)(scope ref C context)
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
ParsingResult parseMinus(C)(scope ref C context)
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
ParsingResult parseZero(C)(scope ref C context)
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
ParsingResult parseDecimalPoint(C)(scope ref C context)
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
ParsingResult parseE(C)(scope ref C context)
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
ParsingResult parseDigit(C)(scope ref C context)
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
ParsingResult parseDigit19(C)(scope ref C context)
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
ParsingResult parseExp(C)(scope ref C context)
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
ParsingResult parseFrac(C)(scope ref C context)
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
ParsingResult parseInt(C)(scope ref C context)
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
ParsingResult parseNumber(C)(scope ref C context)
{
    return context.parseEvent!(
        JsonNode.numberValue,
        parseSequence!(
            parseOption!parseMinus,
            parseInt,
            parseOption!parseFrac,
            parseOption!parseExp));
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

/// parse a quatation mark.
ParsingResult parseQuotationMark(C)(scope ref C context)
{
    return parseChar(context, '"');
}

///
@nogc nothrow @safe unittest
{
    assertMatch!parseQuotationMark("\"");
    assertUnmatch!parseQuotationMark("\'");
    assertUnmatch!parseQuotationMark("");
}

/// parse a escape.
ParsingResult parseEscape(C)(scope ref C context)
{
    return parseChar(context, '\\');
}

///
@nogc nothrow @safe unittest
{
    assertMatch!parseEscape("\\");
    assertUnmatch!parseEscape("\"");
    assertUnmatch!parseEscape("\'");
    assertUnmatch!parseEscape("");
}

/// parse an unescaped character.
ParsingResult parseUnescaped(C)(scope ref C context)
{
    return context.parseChoice!(
        (scope ref c) => c.parseRange('\x20', '\x21'),
        (scope ref c) => c.parseRange('\x23', '\x5B'),
        (scope ref c) => c.parseRange('\x5D', char.max));
}

///
@nogc nothrow @safe unittest
{
    for (char c = '\x00'; ; ++c)
    {
        char[1] source = [c];
        if (c < '\x20' || c == '\x22' || c == '\x5C')
        {
            assertUnmatch!parseUnescaped(source[]);
        }
        else
        {
            assertMatch!parseUnescaped(source[]);
        }

        if (c == char.max)
        {
            break;
        }
    }
}

/// parse a hexdecimal character.
ParsingResult parseHexDigit(C)(scope ref C context)
{
    return context.parseChoice!(
            (scope ref c) => c.parseSet("0123456789ABCDEFabcdef"));
}

///
@nogc nothrow @safe unittest
{
    foreach (c; "01234567890")
    {
        char[1] source = [c];
        assertMatch!parseHexDigit(source[]);
    }

    foreach (c; "ABCDEFabcdef")
    {
        char[1] source = [c];
        assertMatch!parseHexDigit(source[]);
    }

    foreach (c; "Gg. \n\t")
    {
        char[1] source = [c];
        assertUnmatch!parseHexDigit(source[]);
    }
}

/// parse an escaped char.
ParsingResult parseJsonEscapeChar(C)(scope ref C context)
{
    return context.parseSequence!(
            parseEscape,
            parseChoice!(
                (scope ref c) => c.parseSet("\"\\/bfnrt"),
                parseSequence!(
                    (scope ref c) => c.parseChar('u'),
                    parseHexDigit,
                    parseHexDigit,
                    parseHexDigit,
                    parseHexDigit)));
}

///
@nogc nothrow @safe unittest
{
    foreach (c; "\"\\/bfnrt")
    {
        char[2] source = ['\\', c];
        assertMatch!parseJsonEscapeChar(source[]);
    }

    foreach (c; "0aA.,\'")
    {
        char[2] source = ['\\', c];
        assertUnmatch!parseJsonEscapeChar(source[]);
    }

    assertMatch!parseJsonEscapeChar("\\u1234");
    assertMatch!parseJsonEscapeChar("\\u0000");
    assertMatch!parseJsonEscapeChar("\\uabcd");
    assertMatch!parseJsonEscapeChar("\\uABCD");
    assertMatch!parseJsonEscapeChar("\\uffff");
    assertMatch!parseJsonEscapeChar("\\uFFFF");

    assertUnmatch!parseJsonEscapeChar("\\u");
    assertUnmatch!parseJsonEscapeChar("\\u1");
    assertUnmatch!parseJsonEscapeChar("\\u12");
    assertUnmatch!parseJsonEscapeChar("\\u123");
    assertUnmatch!parseJsonEscapeChar("\\ua");
    assertUnmatch!parseJsonEscapeChar("\\uab");
    assertUnmatch!parseJsonEscapeChar("\\uabc");
    assertUnmatch!parseJsonEscapeChar("\\uA");
    assertUnmatch!parseJsonEscapeChar("\\uAB");
    assertUnmatch!parseJsonEscapeChar("\\uABC");
    assertUnmatch!parseJsonEscapeChar("\\U1234");
    assertUnmatch!parseJsonEscapeChar("\\UFFFF");
}

/// parse string literal char.
ParsingResult parseJsonChar(C)(scope ref C context)
{
    return context.parseChoice!(
            parseUnescaped,
            parseJsonEscapeChar);
}

///
@nogc nothrow @safe unittest
{
    assertMatch!parseJsonChar("a");
    assertMatch!parseJsonChar("\\n");

    assertUnmatch!parseJsonChar("\\d");
    assertUnmatch!parseJsonChar("");
}

/// parse string literal.
ParsingResult parseJsonString(C)(scope ref C context)
{
    return context.parseEvent!(
            JsonNode.stringValue,
            parseSequence!(
                parseQuotationMark,
                parseZeroOrMore!parseJsonChar,
                parseQuotationMark));
}

///
@nogc nothrow @safe unittest
{
    assertMatch!parseJsonString(`""`);
    assertMatch!parseJsonString(`"a"`);
    assertMatch!parseJsonString(`"あ"`);
    assertMatch!parseJsonString(`"\\"`);
    assertMatch!parseJsonString(`"\n"`);

    assertMatch!parseJsonString(`"abcde"`);
    assertMatch!parseJsonString(`"あいうえお"`);
    assertMatch!parseJsonString(`"\\\n\t\r\b\f\""`);

    assertUnmatch!parseJsonString(`"`);
    assertUnmatch!parseJsonString(`'`);
    assertUnmatch!parseJsonString(`a`);
    assertUnmatch!parseJsonString(`\`);
    assertUnmatch!parseJsonString(`\n`);
    assertUnmatch!parseJsonString(`"\"`);
    assertUnmatch!parseJsonString(`"a`);
}

/// parse an object member.
ParsingResult parseMember(C)(scope ref C context)
{
    return context.parseEvent!(
            JsonNode.member,
            parseSequence!(
                parseJsonString!C,
                parseNameSeparator!C,
                parseValue!C));
}

///
@nogc nothrow @safe unittest
{
    assertMatch!parseMember(`"":0`);
    assertMatch!parseMember(`"":""`);
    assertMatch!parseMember(`"":[]`);
    assertMatch!parseMember(`"":[""]`);
    assertMatch!parseMember(`"":null`);
    assertMatch!parseMember(`"":true`);
    assertMatch!parseMember(`"":false`);
    assertMatch!parseMember(`""  :  false  `);
    assertMatch!parseMember(`"test":""`);

    assertUnmatch!parseMember(`"":`);
    assertUnmatch!parseMember(`:""`);
    assertUnmatch!parseMember(`0:""`);
    assertUnmatch!parseMember(`null:""`);
    assertUnmatch!parseMember(`true:""`);
    assertUnmatch!parseMember(`false:""`);
    assertUnmatch!parseMember(`[]:""`);
}

/// parse an object.
ParsingResult parseObject(C)(scope ref C context)
{
    return context.parseEvent!(
            JsonNode.object,
            parseSequence!(
                parseBeginObject,
                parseOption!(
                    parseSequence!(
                        parseMember,
                        parseZeroOrMore!(
                            parseSequence!(parseValueSeparator, parseMember)))),
                parseEndObject));
}

///
@nogc nothrow @safe unittest
{
    assertMatch!parseObject("{}");
    assertMatch!parseObject("  {  }  ");

    assertMatch!parseObject(`{"":0}`);
    assertMatch!parseObject(`{"":0.0}`);
    assertMatch!parseObject(`{"":0.0e15}`);
    assertMatch!parseObject(`{"":null}`);
    assertMatch!parseObject(`{"":true}`);
    assertMatch!parseObject(`{"":false}`);
    assertMatch!parseObject(`{"":""}`);
    assertMatch!parseObject(`{"":[]}`);
    assertMatch!parseObject(`{"":{}}`);
    assertMatch!parseObject(`{"":[{}]}`);
    assertMatch!parseObject(`{"":[{"":{}}]}`);
    assertMatch!parseObject(`{"a":[{"b":{"c":[{},{},{},"",0,1,true,null]}}]}`);

    assertMatch!parseObject(`{"a":0}`);
    assertMatch!parseObject(`{"ab":0.0}`);
    assertMatch!parseObject(`{"abc":0.0e15}`);
    assertMatch!parseObject(`{"a":null}`);
    assertMatch!parseObject(`{"ab":true}`);
    assertMatch!parseObject(`{"abc":false}`);
    assertMatch!parseObject(`{"ab":""}`);
    assertMatch!parseObject(`{"":""}`);

    assertMatch!parseObject(`{
        "number": 0,
        "true": true,
        "false": false,
        "s": "abc",
        "array": [0, 1, 2, 3],
        "object": { "a": 0, "b": ""}
   }`);

    assertUnmatch!parseObject("{");
    assertUnmatch!parseObject(`{""`);
    assertUnmatch!parseObject(`{"":`);
    assertUnmatch!parseObject(`{"":0`);
    assertUnmatch!parseObject(`{"":0,"abc":"",}`);
    assertUnmatch!parseObject("}");
}

/// parse an array.
ParsingResult parseArray(C)(scope ref C context)
{
    return context.parseEvent!(
            JsonNode.array,
            parseSequence!(
                parseBeginArray,
                parseOption!(
                    parseSequence!(
                        parseValue,
                        parseZeroOrMore!(
                            parseSequence!(
                                parseValueSeparator, parseValue)))),
               parseEndArray));
}

///
@nogc nothrow @safe unittest
{
    assertMatch!parseArray("[]");
    assertMatch!parseArray("  [  ]  ");

    void assertMatchValue(string valueString)()
    {
        assertMatch!parseArray("[" ~ valueString ~ "]");
        assertMatch!parseArray("  [  " ~ valueString ~ "]  ");
        assertMatch!parseArray("[" ~ valueString ~ "," ~ valueString ~ "]");
        assertMatch!parseArray(
            "  [  " ~ valueString ~ " , " ~ valueString ~ " , " ~ valueString ~ "  ]  ");
    }

    assertMatchValue!("false");
    assertMatchValue!("true");
    assertMatchValue!("null");
    assertMatchValue!("0");
    assertMatchValue!("0.0");
    assertMatchValue!(`""`);
    assertMatchValue!(`"abc"`);
    assertMatchValue!(`"\b\f\n\r\t\uFFFF\""`);

    assertMatch!parseArray("[[]]");
    assertMatch!parseArray("[[],[],[]]");
    assertMatch!parseArray(`[[1],["a"],[]]`);

    assertUnmatch!parseArray("[");
    assertUnmatch!parseArray("]");

    void assertUnmatchValue(string valueString)()
    {
        assertUnmatch!parseArray("[" ~ valueString ~ " " ~ valueString ~ "]");
        assertUnmatch!parseArray("[" ~ valueString ~ ",]");
        assertUnmatch!parseArray("[" ~ valueString ~ "," ~ valueString ~ ",]");
    }
}

/// parse a value.
ParsingResult parseValue(C)(scope ref C context)
{
    return context.parseChoice!(
            parseFalse!C,
            parseNull!C,
            parseTrue!C,
            parseObject!C,
            parseArray!C,
            parseNumber!C,
            parseJsonString!C);
}

/// parse JSON.
ParsingResult parseJson(C)(scope ref C context)
{
    return context.parseValue;
}

