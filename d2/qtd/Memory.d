module qt.Memory;

import
	core.exception,
	core.memory,
	core.stdc.stdlib;

alias void delegate(Object) DEvent;
extern(C) void rt_attachDisposeEvent(Object o, DEvent e);
extern(C) void rt_detachDisposeEvent(Object o, DEvent e);
extern(C) Object _d_toObject(void* p);

/**
	Object stack.
*/
final class StackAlloc
{
	alias typeof(this) This;
	private void* _data;
	
	private static size_t align16(size_t size)
	{
	    return size + 16 - (size - size & ~15);        
	}

	/**
	*/
	this(size_t size)
	{
	    _data = (new void[size]).ptr;
	}
    
	/**
	*/
	void* alloc(size_t size)
	{
	    void* res = _data;
	    _data += align16(size);
	    return res;            
	}

	/**
	*/
	void free(size_t size)
	{
	    _data -= align16(size);
	}
}

/**
	Size of the object stack.
*/
enum stackSize = 1024 * 1024;

/**
	Returns the object stack for the current thread.
*/
StackAlloc stackAlloc()
{
static StackAlloc stackAlloc;
if (!stackAlloc)
	stackAlloc = new StackAlloc(stackSize);
return stackAlloc;
}

/**
	C heap allocator.
*/
struct CAlloc
{
	/**
	*/
	static void* alloc(size_t size, uint flags = 0)
	{
		auto p = malloc(size);
		if (!p)
			onOutOfMemoryError;
		return p;
	}
	
	/**
	*/	
	static void* realloc(void* addr, size_t size)
	{
		auto p = realloc(addr, size);
		if (!p)
			onOutOfMemoryError;
		return p;
	}
	
	/**
	*/
	static void free(void* p, size_t size = 0)
	{
		free(p);		
	}
}

/**
	GC heap allocator.
*/
struct GCAlloc
{
	static void* alloc(size_t size, uint flags = 0)
	{
		return GC.malloc(size, flags);
	}
	
	static void* realloc(void* addr, size_t size)
	{
		return GC.realloc(addr, size);
	}
	
	static void free(void* addr, size_t size = 0)
	{
		GC.free(addr);
	}
}