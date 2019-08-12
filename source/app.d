module app;

private:

void doUnitTest(alias M)() @nogc nothrow
{
    static foreach(u; __traits(getUnitTests, M))
    {
        u();
    }
}

void doAllUnitTest() @nogc nothrow
{
    import bcparser.context;
    doUnitTest!(bcparser.context)();

    import bcparser.event;
    doUnitTest!(bcparser.event)();

    import bcparser.memory;
    doUnitTest!(bcparser.memory)();

    import bcparser.parsers;
    doUnitTest!(bcparser.parsers)();

    import bcparser.result;
    doUnitTest!(bcparser.result)();

    import bcparser.source;
    doUnitTest!(bcparser.source)();

    import bcparser.tree;
    doUnitTest!(bcparser.tree)();
}

version(D_BetterC)
{
    /**
    test runner for BetterC
    */
    extern(C) void main()
    {
        doAllUnitTest();
    }
}

