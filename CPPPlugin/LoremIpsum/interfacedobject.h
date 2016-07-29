#ifndef INTERFACEDOBJECT_H
#define INTERFACEDOBJECT_H

#include <olectl.h>

#define UNKNOWN_INTERFACE_IMPLEMENTATION \
HRESULT STDMETHODCALLTYPE QueryInterface(const IID &iid, void **ppv) { \
    if (!ppv) return E_INVALIDARG; \
    *ppv = NULL; \
    if (iid == IID_IUnknown) { \
        *ppv = static_cast<IUnknown*>(this); \
        AddRef(); \
        return NOERROR; \
    } \
    return queryInterface(iid, ppv); \
} \
ULONG STDMETHODCALLTYPE AddRef(){ return InterfacedObject::addRef(); } \
ULONG STDMETHODCALLTYPE Release(){ return InterfacedObject::release(); }

class InterfacedObject
{
public:
    virtual ~InterfacedObject(){}

protected:
    HRESULT queryInterface(const IID &iid, void **ppv)
    {
        (void)iid;
        *ppv = NULL;
        return E_NOINTERFACE;
    }

    ULONG addRef()
    {
        return InterlockedIncrement(&m_cRef);
    }

    ULONG release()
    {
        ULONG ulRefCount = InterlockedDecrement(&m_cRef);
        if (0 == ulRefCount)
        {
            delete this;
        }
        return ulRefCount;
    }

private:
    ULONG m_cRef = 0;
};

#endif // INTERFACEDOBJECT_H
