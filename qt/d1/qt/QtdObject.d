/**
*
*  Copyright: Copyright QtD Team, 2008-2009
*  License: <a href="http://www.boost.org/LICENSE_1_0.txt>Boost License 1.0</a>
*  Authors: Max Samukha, Eldar Insafutdinov
*
*  Copyright QtD Team, 2008-2009
*  Distributed under the Boost Software License, Version 1.0.
*  (See accompanying file boost-license-1.0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
* 
*/

module qt.QtdObject;

import qt.Signal;
import tango.core.Memory;
debug (QtdVerbose)
    import tango.io.Stdout;


enum QtdObjectFlags : ubyte
{
    none,
    // The native object will not be deleted when the wrapper is deleted
    skipNativeDelete          = 0b0001,
    skipDDelete               = 0b0010,
    hasDId                    = 0b0100,
    stackAllocated            = 0b1000
    /+
    // The will be deleted when is goes out of scope. Implies skipNativeDelete
    scoped                    = 0x08
    +/
}

class MetaObject
{
    alias typeof(this) This;
    
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
    
    /++
        Next sibling on this derivation level                
    +/
    final This next()
    {
        return _next;
    }
    
    /++
        Head of the linked list of derived classes    
    +/
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


abstract class QtdMetaObject : MetaObject
{
    QtdObjectBase function(void* nativeId, QtdObjectFlags flags) _createWrapper;
    
    void construct(T : QtdObject, Concrete = T)()
    {
        super.construct!(T);
        _createWrapper = &T.__createWrapper;
    }
}

/++
    Meta-object for polymorphic Qt classes.
+/
final class QtdMetaObject : MetaObject
{
    alias typeof(this) This;
    
    private void* _typeId;    
            
    this(void* typeId, QtdMetaObject base)
    {
        super(base);
        _typeId = typeId;
    }
    
    QtdObject wrap(void* nativeId, void* typeId, QtdObjectFlags flags = QtdObjectFlags.skipNativeDelete)
    {
        if (typeId == _typeId)
        {
            /+
            if (auto p = nativeId in _nativeToDMap)
                return *p;
            +/
        }
        else
        {
            for (auto mo = static_cast!(This)(_firstDerived); mo; mo = static_cast!(This)(mo._next))
            {
                if (auto obj = mo.wrap(nativeId, typeId, flags))
                    return obj;
            }
        }
        
        return _createWrapper(nativeId, flags);
    }
}

abstract class QtdObjectBase
{
    alias typeof(this) This;
    
    void* __nativeId;
    QtdObjectFlags __flags;
    
    new (size_t size, QtdObjectFlags flags = QtdObjectFlags.none)
    {
        return flags & QtdObjectFlags.stackAllocated ? __stackAlloc.alloc(size) :
            GC.malloc(size, GC.BlkAttr.FINALIZE);
    }
    
    delete (void* p)
    {
        if ((cast(This)p).__flags & QtdObjectFlags.stackAllocated)
            __stackAlloc.free(this.classinfo.init.length);
        else
            GC.free(p);
    }
    
    this(void* nativeId, QtdObjectFlags flags = QtdObjectFlags.none)
    {
        __nativeId = nativeId;
        __flags = flags;
        debug(QtdVerbose) __print("D wrapper constructed");
    }
    
    debug(QtdVerbose)
    {    
        void __print(string msg)
        {
            Stdout.formatln("{} (native: {}, D: {}, flags 0b{:b})", msg, __nativeId, cast(void*)this, __flags);
        }
    }
    
    protected void __deleteNative()
    {
        assert(false, "Cannot delete native " 
            ~ this.classinfo.name 
            ~ " because it has no public destructor");
    }
    
    ~this()
    {
        debug(QtdVerbose) __print("In QtdObjectBase destructor");
        
        if (!(__flags & QtdObjectFlags.skipNativeDelete))
        {
            __flags |= QtdObjectFlags.skipDDelete;
            debug(QtdVerbose) __print("About to call native delete");
            __deleteNative;
        }     
    }
}

// Base class for by-reference objects
abstract class QtdObject : QtdObjectBase
{        
    private
    {
        typeof(this) __next, __prev;
        static typeof(this) __root;
    }
    
    /++
        Use this method instead of 'is' operator to check if two D objects
        wrap the same native object.
    +/
    bool isSame(QtdObject other)
    {
        return __nativeId == other.__nativeId;
    }
       
    mixin SignalHandlerOps;

    this(void* nativeId, QtdObjectFlags flags)
    {
        super (nativeId, flags);       
        if (!(flags & QtdObjectFlags.skipNativeDelete))
            __pin;
    }
    
    final void __pin()
    {
        debug(QtdVerbose) __print("Pinning");
        
        __next = __root;
        __root = this;
        if (__next)
            __next.__prev = this;        
    }
    
    final void __unpin()
    {
        debug(QtdVerbose) __print("Unpinning");
                
        if (__prev)
            __prev.__next = __next;
        else
            __root = __next;
        
        if (__next)      
            __next.__prev = __prev;
    }
    
    void __nativeOwnership(bool value)
    {       
        if (value)
        {
            assert (!(__flags & QtdObjectFlags.skipNativeDelete));            
            __flags |= QtdObjectFlags.skipNativeDelete;
            __unpin;
        }
        else
        {
            assert (__flags & QtdObjectFlags.skipNativeDelete);            
            __flags = __flags &= ~QtdObjectFlags.skipNativeDelete;
            __pin;
        }
    }
      
    ~this()
    {
        debug(QtdVerbose) __print("In QtdObject destructor");
        
        if (__prev || __root is this)
            __unpin;
    }    
}

/++
+/
void dispose(QtdObjectBase obj)
{
    obj.__flags &= ~QtdObjectFlags.skipNativeDelete;
    delete obj;
}

// Called from shell destructors
extern(C) void qtd_delete_d_object(void* dId)
{
    auto obj = cast(QtdObject)dId;
    debug(QtdVerbose) obj.__print("In qtd_delete_d_object");
    
    if (!(obj.__flags & QtdObjectFlags.skipDDelete))
    {
        // Avoid deleting native object twice
        obj.__flags |= QtdObjectFlags.skipNativeDelete;
        delete obj;
    }
}