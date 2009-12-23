/**
*
*  Copyright: Copyright QtD Team, 2008-2009
*  License: <a href="http://www.boost.org/LICENSE_1_0.txt>Boost License 1.0</a>
*
*  Copyright QtD Team, 2008-2009
*  Distributed under the Boost Software License, Version 1.0.
*  (See accompanying file boost-license-1.0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
*
*/

module qtd.QtdObject;

import
	core.memory,
	qtd.Signal,
	qtd.Core,
	qtd.Memory,
	qtd.Array;

struct ScopeObject(T : QtdObjectBase)
{
	T obj;
	alias obj this;
	
	~this()
	{
		if (obj.__flags & QtdObjectFlags.stackAllocated)
		{
			delete obj;
		}
	}
}

ScopeObject!T scopeObject(T : QtdObjectBase)(void* nativeId, QtdObjectFlags flags = QtdObjectFlags.none)
{
	ScopeObject!T sObj;
	sObj.obj = T.__wrap(nativeId, cast(QtdObjectFlags)(flags | QtdObjectFlags.skipNativeDelete
			| QtdObjectFlags.stackAllocated)); 
	return sObj;
}

class MetaObject
{
    alias typeof(this) This;
    mixin SignalHandlerOps;
    
    private
    {
        MetaObject _base;
        ClassInfo _classInfo;
    }
    
    //COMPILER BUG: not accessible from QMetaObject
    protected
    {
        This _firstDerived;
        This _next;
    }

    private void addDerived(This mo)
    {
        mo._next = _firstDerived;
        _firstDerived = mo;
    }
    
    /**
        Next sibling on this derivation level                
    */
    final This next()
    {
        return _next;
    }
    
    /**
        Head of the linked list of derived classes    
    */
    final This firstDerived()
    {
        return _firstDerived;
    }
    
    // NOTE: construction is split between this non-templated constructor and 'construct' function below.    
    this(This base)
    {
        if (base)        
        {
            base.addDerived(this);
            _base = base;
        }
    }
    
    // TODO: can be removed when D acquires templated constructors
    void construct(T : Object)()
    {
        _classInfo = T.classinfo;
    }
        
    final This base()
    {
        return _base;
    }
    
    final ClassInfo classInfo()
    {
        return _classInfo;
    }  
}

/**
*/
abstract class QtdMetaObjectBase : MetaObject
{
	alias QtdObjectBase function(void* nativeId, QtdObjectFlags flags) CreateWrapper; 
    private	void* _nativeId;
    protected CreateWrapper _createWrapper;
    
    this(void* nativeId, QtdMetaObjectBase base, CreateWrapper createWrapper)
    {
        super(base);
        _nativeId = nativeId;
        _createWrapper = createWrapper;
    }
    
    final void* nativeId()
    {
    	return _nativeId;
    }
}

/**
*/
final class QtdMetaObject : QtdMetaObjectBase
{
    alias typeof(this) This;
    
    private
    {
    	// TODO: optimize to use a sorted list or something
    	// to speed up accesses.
    	QtdObject[] _refs;
    }
            
    this(void* nativeId, QtdMetaObjectBase base, CreateWrapper createWrapper)
    {
        super(nativeId, base, createWrapper);
    }
    
    void addRef(QtdObject object)
    {
    	append!CAlloc(_refs, object);
    }
    
    void removeRef(QtdObject object)
    {
    	remove!CAlloc(_refs, object);
    }
    
    QtdObject wrap(void* nativeObjId, void* typeId, QtdObjectFlags flags = QtdObjectFlags.none)
    {    	
        if (typeId == nativeId)
        {
        	// TODO: optimize
            foreach (r; _refs)
            {
            	if (r.__nativeId == nativeObjId)
            		return r; 
            }
        }
        else
        {  
            for (auto mo = static_cast!(This)(_firstDerived); mo; mo = static_cast!(This)(mo._next))
            {
                if (auto obj = mo.wrap(nativeObjId, typeId, flags))
                    return obj;
            }
        }
                
        return static_cast!(QtdObject)(_createWrapper(nativeObjId, flags));
    }
}

/**
 	Inserted into any QtD object.
*/

/**
*/
enum QtdObjectFlags : ubyte
{
    none,    
    // The native object will not be deleted when the wrapper is deleted
    skipNativeDelete          = 0b0000_0001,
    // The wrapper will not be deleted when the native object is deleted
    skipDDelete               = 0b0000_0010,
    // The wrapper reference is stored in the shell
    hasDId                    = 0b0000_0100,    
    // The wrapper is allocated on thread-local stack
    stackAllocated            = 0b0000_1000,
    // is a QObject
    isQObject				  = 0b0001_0000,
    // The wrapper is not subject to GC
    pinned   				  = 0b0010_0000
}

class QtdObjectBase
{
	// TODO: probably, __ should be replaced with qtd_, as __ are reserved by the language  
	/// Internal members. Do not change.
	void* __nativeId;
	/// ditto
    QtdObjectFlags __flags;
    
    private
    {
	    QtdObjectBase __prev, __next;
	    static QtdObjectBase __root;
    }
	
	new (size_t size, QtdObjectFlags flags = QtdObjectFlags.none)
    {
        return flags & QtdObjectFlags.stackAllocated ? stackAlloc.alloc(size) :
            GC.malloc(size, GC.BlkAttr.FINALIZE);
    }
    
    delete (void* p)
    {
        if ((cast(typeof(this))p).__flags & QtdObjectFlags.stackAllocated)
            stackAlloc.free(this.classinfo.init.length);
        else
            GC.free(p);
    }
    
    /**
    	Tests if the other wrapper points to the same native object.
        Should be always used when two objects that may have
        duplicate wrappers are compared for identity.
    */
    bool __is(QtdObjectBase other)
    {
    	return __nativeId == other.__nativeId;     	
    }
    
    /**
		Constructs the object.
	*/  
	this(void* nativeId, QtdObjectFlags flags = QtdObjectFlags.none)
	{
		__nativeId = nativeId;
		__flags = flags;	    
	}
	
	/**
		Forces destruction of the native object.
	*/
	final void __dispose()
	{
		// Avoid deleting the wrapper twice
		__flags |= QtdObjectFlags.skipDDelete;
	    __deleteNative;
	}
	
	/**
		Disables garbage collection for this object.
	*/
	final void __pin()
	{
		assert (!__isPinned);
	    __next = __root;
	    __root = this;
	    if (__next)
	    	__next.__prev = this;				
	}
	
	/**
		Enables garbage collection for this object.
	*/
	final void __unpin()
	{
		assert (__isPinned);
        if (__prev)
        {
            __prev.__next = __next;
            __prev = null;
        }
        else
            __root = __next;
	}
	
	/**
	     
	*/
    /+
	void __ownership(QtdOwnership native)
	{
		switch(own)
		{
			case QtdOwnership.cpp:
				if (!__isPinned)
					__pin;
				break;
			case QtdOwnership.cpp:
				if(!__isPinned)
					__pin;
				break;
			case QtdOwnership.def:
				assert(false, "Not implemented");
				if (!(__flags & QtdObjectFlags.hasDId))				    				    
					__pin;
			default:
				assert(false);
		}
	}
    +/
	
	/**
		Returns true if garbage collection for this object is disabled.
	*/
	final bool __isPinned()
	{
		return __prev || __root is this;				
	}
	
	// COMPILER BUG: 3206
	protected void __deleteNative()
	{
	    assert(false);
	}
	
	~this()
	{
		if (!(__flags & QtdObjectFlags.skipNativeDelete))    	
	        __dispose;
	}
}

/**
 	Base class for non-QObjects.
*/
abstract class QtdObject : QtdObjectBase
{	
	alias typeof(this) This;
	
	// TODO: must be abstract
	QtdMetaObject metaObject()
	{
		return null;
	}
	
    /**
    	Constructs the object.
    */
    this(void* nativeId, QtdObjectFlags flags = QtdObjectFlags.none)
    {
    	super(nativeId, flags);
        if (!(__flags & QtdObjectFlags.hasDId))
        	metaObject.addRef(this);
    }
    
    ~this()
    {
    	if (!(__flags & QtdObjectFlags.hasDId))
	    	metaObject.removeRef(this);
    }
    
    mixin SignalHandlerOps;
}

// Called from shell destructors
extern(C) void qtd_delete_d_object(void* dId)
{
    auto obj = cast(QtdObjectBase)dId;
    
    if (!(obj.__flags & QtdObjectFlags.skipDDelete))
    {
        // Avoid deleting native object twice
        obj.__flags |= QtdObjectFlags.skipNativeDelete;
        delete obj;
    }
}

/+
extern(C) void qtd_ownership(void* dId, QtdOwnership own)
{
	auto obj = cast(QtdObjectBase)dId;
	obj.__ownership = own;
}
+/