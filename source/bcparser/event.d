/**
Parsing event module.
*/
module bcparser.event;

import bcparser.source : isSource, SourcePositionType;

/**
Parsing event.

Params:
    S = source type.
*/
struct ParsingEvent(S) if(isSource!S)
{
    /**
    Event name.
    */
    string name;

    /**
    Event position.
    */
    SourcePositionType!S position;
}

