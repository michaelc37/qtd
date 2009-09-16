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

#ifndef QTD_CORE_H
#define QTD_CORE_H

#include <QAbstractItemModel>
#include <QObject>

#if defined WIN32
  #define DLL_PUBLIC __declspec(dllexport)
#else
  #define DLL_PUBLIC
#endif

#ifdef CPP_SHARED
  #define QTD_EXPORT(TYPE, NAME, ARGS) \
    extern "C" typedef TYPE (*pf_##NAME)ARGS; \
    extern "C" pf_##NAME qtd_get_##NAME();
  #define QTD_EXPORT_VAR(NAME) \
    pf_##NAME m_##NAME;        \
    extern "C" DLL_PUBLIC pf_##NAME qtd_get_##NAME() { return m_##NAME; }
#define QTD_EXPORT_VAR_SET(NAME, VALUE) \
    m_##NAME = (pf_##NAME) VALUE
#else
  #define QTD_EXPORT(TYPE, NAME, ARGS) \
    extern "C" TYPE NAME ARGS;
#endif


//TODO: user data ID must be registered with QObject::registerUserData;
#define userDataId 0

struct QModelIndexAccessor {
	int row;
	int col;
	void *ptr;
	QAbstractItemModel *model;
};

struct DArray {
    size_t length;
    void* ptr;
};

class QtD_Entity
{
public:
    void* dId;

    QtD_Entity(void* id) : dId(id)
    {
    }
};

class QtD_QObjectEntity : public QtD_Entity, public QObjectUserData
{
public:
    QtD_QObjectEntity(QObject *qObject, void *dId);
    virtual ~QtD_QObjectEntity();
    void destroyEntity(QObject *qObject = NULL);
    static QtD_QObjectEntity* getQObjectEntity(const QObject *qObject);
};

#define Array DArray

#ifdef CPP_SHARED
typedef void (*pfunc_abstr)();
#endif

QTD_EXPORT(void, qtd_toUtf8, (const unsigned short* arr, uint size, void* str))
QTD_EXPORT(void, qtd_dummy, ())
QTD_EXPORT(void, qtd_delete_d_object, (void* dPtr))

#ifdef CPP_SHARED
#define qtd_toUtf8 qtd_get_qtd_toUtf8()
#define qtd_dummy qtd_get_qtd_dummy()
#define qtd_delete_d_object qtd_get_qtd_delete_d_object()
#endif

extern "C" QModelIndex qtd_to_QModelIndex(QModelIndexAccessor mia);
extern "C" QModelIndexAccessor qtd_from_QModelIndex(const QModelIndex &index);



#endif // QTD_CORE_H
