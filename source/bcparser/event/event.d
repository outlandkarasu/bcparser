/**
Parsing events module.
*/
module bcparser.event.event;

/**
Parsing event.
*/
struct ParsingEvent
{
    /// event tag name.
    string tag;

    /// event position.
    size_t position;
}

