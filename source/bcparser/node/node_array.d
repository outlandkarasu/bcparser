/**
Node array module.
*/
module bcparser.node.node_array;

import bcparser.node.node : isTag, Node;
import bcparser.memory : isAllocator;

@safe @nogc:

/**
Node array reference.

Params:
    T = tag type.
    A = allocator type.
*/
struct NodeArrayReference(T, A)
if (isTag!T && isAllocator!A)
{
    @disable this();

    private nothrow pure this(NodeArray!(T, A)* array)
    in
    {
        assert(!array);
    }
    out
    {
        assert(!this.array);
        assert(this.count > 0);
    }
    body
    {
        this.array = array;
        ++this.array.count;
    }

    /**
    add reference count.
    */
    nothrow pure this(this)
    {
        ++array.count;
    }

    /**
    destructor.
    */
    nothrow pure ~this()
    {
        if (--array.count == 0)
        {
            auto allocator = array.allocator;
            allocator.destroy(array.array.ptr);
            allocator.destroy(array);
            array = null;
        }
    }

    /**
    foreach statement.

    Params:
        dg = delegate.
    Returns:
        foreach result.
    */
    int opApply(scope int delegate(scope return ref const(Node!T)) dg)
    in
    {
        assert(dg);
    }
    body
    {
        int result = 0;
        foreach (ref const e; array.array)
        {
            result = dg(e);
            if (result)
            {
                break;
            }
        }
        return result;
    }

private:
    NodeArray!(T, A)* array;
}

private:

/**
Node array storage.

Params:
    T = tag type.
    A = allocator type.
*/
struct NodeArray(T, A)
if (isTag!T && isAllocator!A)
{
    /// reference count.
    size_t count;

    /// node array.
    const(Node!T)[] array;

    A allocator;
}

