module qt.core.QMetaObject;

import qt.QGlobal;
import qt.core.QObject;
import qt.QtdObject;

/++
    Meta-object for QObject classes.
+/
final class QMetaObject : MetaObject
{
    alias typeof(this) This;
    
    private void* _nativeId;
    
    this(void* nativeId, QMetaObject base)
    {
        _nativeId = nativeId;
        super(base);
    }    
    
    /++
    +/
    void* nativeId()
    {
        return _nativeId;
    }
    
    private QMetaObject lookupDerived(void*[] moIds)
    {
        assert (moIds.length >= 1);
                
        for (auto mo = static_cast!(This)(firstDerived); mo !is null; mo = static_cast!(This)(mo.next))
        {
            if (mo._nativeId == moIds[0])
            {
                if (moIds.length == 1) // exact match found
                    return mo;
                else // look deeper
                    return mo.lookupDerived(moIds[1..$]);
            }
        }
        
        // no initialized wrapper that matches the native object.
        // use the base class wrapper
        return this;
    }
    
    QObject wrap(void* nativeObjId, QtdObjectFlags flags = QtdObjectFlags.none)
    {
        QObject result;
        
        if (nativeObjId)
        {
            result = cast(QObject)qtd_get_d_qobject(nativeObjId);            
            if (!result)
            {
                auto moId = qtd_QObject_metaObject(nativeObjId);
                if (_nativeId == moId)
                     result = _createWrapper(nativeObjId, flags);
                else
                {
                    // get native metaobjects for the entire derivation lattice
                    // up to, but not including, the current metaobject.
                    size_t moCount = 1;
                    
                    for (void* tmp = moId;;)
                    {
                        tmp = qtd_QMetaObject_superClass(tmp);                        
                        if (!tmp)
                            return null;
                        
                        if (tmp == _nativeId)                        
                            break;
                        moCount++;
                    }
                   
                    void*[] moIds = (cast(void**)alloca(moCount * (void*).sizeof))[0..moCount];

                    moIds[--moCount] = moId;
                    while (moCount > 0)
                        moIds[--moCount] = moId = qtd_QMetaObject_superClass(moId);
                                    
                    result = lookupDerived(moIds)._createWrapper(nativeObjId, flags);
                }                
            }
        }

        return result;
    }
}

extern(C) void* qtd_QMetaObject_superClass(void* nativeId);