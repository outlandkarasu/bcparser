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

    /**
    bool to parsing result.

    Params:
        b = match or unmatch.
    Returns:
        parsing result.
    */
    static ref immutable(ParsingResult) of(bool b) nothrow pure
    {
        return b ? match : unmatch;
    }

    /**
    Returns:
        true if matched.
    */
    @property bool isMatch() const nothrow pure
    {
        return resultType_ == Type.match;
    }

    ///
    @nogc nothrow pure @safe unittest
    {
        assert(ParsingResult.match.isMatch);
        assert(!ParsingResult.unmatch.isMatch);
        assert(!ParsingResult.createError("test").isMatch);
    }

    /**
    Returns:
        true if unmatched.
    */
    @property bool isUnmatch() const nothrow pure
    {
        return resultType_ == Type.unmatch;
    }

    ///
    @nogc nothrow pure @safe unittest
    {
        assert(!ParsingResult.match.isUnmatch);
        assert(ParsingResult.unmatch.isUnmatch);
        assert(!ParsingResult.createError("test").isUnmatch);
    }

    /**
    Returns:
        true if has error.
    */
    @property bool hasError() const nothrow pure
    {
        return resultType_ == Type.error;
    }

    ///
    @nogc nothrow pure @safe unittest
    {
        assert(!ParsingResult.match.hasError);
        assert(!ParsingResult.unmatch.hasError);
        assert(ParsingResult.createError("test").hasError);
    }

    /**
    Returns:
        error message.
    */
    @property string message() const nothrow pure
    {
        return message_;
    }

    ///
    @nogc nothrow pure @safe unittest
    {
        assert(ParsingResult.match.message == null);
        assert(ParsingResult.unmatch.message == null);
        assert(ParsingResult.createError("test").message == "test");
    }

    /**
    Params:
        op = operator.
        rhs = right hand side.
    Returns:
        match and match => match
        match and unmatch => unmatch
        match and error => error
        unmatch and unmatch => unmatch
        unmatch and error => error
    */
    ParsingResult opBinary(string op)(auto scope ref const(ParsingResult) rhs) const nothrow pure
        if (op == "&")
    {
        final switch (resultType_)
        {
            case Type.match:
                return rhs;
            case Type.unmatch:
                return rhs.hasError ? rhs : this;
            case Type.error:
                return this;
        }
    }

    ///
    @nogc nothrow pure @safe unittest
    {
        immutable error = ParsingResult.createError("test");

        assert((ParsingResult.match & ParsingResult.match).isMatch);
        assert((ParsingResult.unmatch & ParsingResult.unmatch).isUnmatch);
        assert((error & error).hasError);

        assert((ParsingResult.unmatch & ParsingResult.match).isUnmatch);
        assert((ParsingResult.match & ParsingResult.unmatch).isUnmatch);

        assert((ParsingResult.match & error).hasError);
        assert((error & ParsingResult.match).hasError);

        assert((ParsingResult.unmatch & error).hasError);
        assert((error & ParsingResult.unmatch).hasError);
    }

    /**
    Params:
        op = operator.
        rhs = right hand side.
    Returns:
        match and match => match
        match and unmatch => unmatch
        match and error => error
        unmatch and unmatch => unmatch
        unmatch and error => error
    */
    ParsingResult opBinary(string op)(auto scope ref const(ParsingResult) rhs) const nothrow pure
        if (op == "|")
    {
        final switch (resultType_)
        {
            case Type.match:
                return rhs.hasError ? rhs : this;
            case Type.unmatch:
                return rhs;
            case Type.error:
                return this;
        }
    }

    ///
    @nogc nothrow pure @safe unittest
    {
        immutable error = ParsingResult.createError("test");

        assert((ParsingResult.match | ParsingResult.match).isMatch);
        assert((ParsingResult.unmatch | ParsingResult.unmatch).isUnmatch);
        assert((error | error).hasError);

        assert((ParsingResult.unmatch | ParsingResult.match).isMatch);
        assert((ParsingResult.match | ParsingResult.unmatch).isMatch);

        assert((ParsingResult.match | error).hasError);
        assert((error | ParsingResult.match).hasError);

        assert((ParsingResult.unmatch | error).hasError);
        assert((error | ParsingResult.unmatch).hasError);
    }

    /**
    Returns:
        true if matched.
    */
    T opCast(T)() const nothrow pure
        if (is(T == bool))
    {
        return isMatch;
    }

    ///
    @nogc nothrow pure @safe unittest
    {
        assert(ParsingResult.match);
        assert(!ParsingResult.unmatch);
        assert(!ParsingResult.createError("test"));
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
    string message_ = "uninitialized";
}

///
@nogc nothrow pure @safe unittest
{
    ParsingResult result;
    assert(result.hasError);
    assert(result.message == "uninitialized");
}


