/**
Parsing result module.
*/
module bcparser.result;

/**
Parsing result.
*/
struct ParsingResult
{
@nogc @safe:

    /**
    Match result.
    */
    static immutable match = ParsingResult(Type.match, null);

    /**
    Unmatch result.
    */
    static immutable unmatch = ParsingResult(Type.unmatch, null);

    /**
    create error result.

    Params:
        message = error message.
    Returns:
        error result.
    */
    static ParsingResult createError(string message) nothrow pure
    in
    {
        assert(message.length > 0);
    }
    out(result)
    {
        assert(result.hasError);
        assert(result.message == message);
    }
    body
    {
        return ParsingResult(Type.error, message);
    }

    @disable this();

    /**
    Returns:
        true if matched.
    */
    @property bool isMatch() const nothrow pure
    {
        return resultType_ == Type.match;
    }

    /**
    Returns:
        true if unmatched.
    */
    @property bool isUnmatch() const nothrow pure
    {
        return resultType_ == Type.unmatch;
    }

    /**
    Returns:
        true if has error.
    */
    @property bool hasError() const nothrow pure
    {
        return resultType_ == Type.error;
    }

    /**
    Returns:
        error message.
    */
    @property string message() const nothrow pure
    {
        return message_;
    }

private:

    enum Type
    {
        /// parsing result is unmatch.
        unmatch = 0,

        /// parsing result is match.
        match = 1,

        /// parsing result is error.
        error = -1,
    }

    this(Type resultType, string message) nothrow pure return
    {
        this.resultType_ = resultType;
        this.message_ = message;
    }

    Type resultType_ = Type.error;
    string message_ = "uninitialized.";
}

///
@nogc nothrow pure @safe unittest
{
    // match result.
    assert(ParsingResult.match.isMatch);
    assert(!ParsingResult.match.isUnmatch);
    assert(!ParsingResult.match.hasError);
    assert(ParsingResult.match.message == null);

    // unmatch result.
    assert(!ParsingResult.unmatch.isMatch);
    assert(ParsingResult.unmatch.isUnmatch);
    assert(!ParsingResult.unmatch.hasError);
    assert(ParsingResult.unmatch.message == null);

    // error result.
    immutable error = ParsingResult.createError("test error");
    assert(!error.isMatch);
    assert(!error.isUnmatch);
    assert(error.hasError);
    assert(error.message == "test error");
}

