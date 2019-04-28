module app;

version(D_BetterC)
{
    /**
    test runner for BetterC
    */
    extern(C) void main()
    {
        static foreach(u; __traits(getUnitTests, __traits(parent, main)))
        {
            u();
        }
    }
}

