module bcparser.result;

import bcparser.node : isTag, Node;

/**
parsing result.

Params:
    T = tag type.
*/
struct Result(T) if (isTag!T)
{
    /// true if matched parser.
    bool match;

    /// result nodes.
    const(Node!T)[] nodes;
}

