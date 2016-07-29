#ifndef TEXTPROCESSORINFO_H
#define TEXTPROCESSORINFO_H

#include "PluginAPI/PluginAPI_TLB.h"
#include "interfacedobject.h"
#include "QDebug"

class TextProcessorInfo : public ITextProcessorInfo, InterfacedObject
{
public: // ITextProcessorInfo
    HRESULT STDMETHODCALLTYPE get_Name(BSTR* Value);
    HRESULT STDMETHODCALLTYPE get_ID(GUID* Value);
    HRESULT STDMETHODCALLTYPE get_Version(BSTR* Value);

    HRESULT queryInterface(const IID &iid, void **ppv)
    {
        if (iid == IID_ITextProcessorInfo) {
            *ppv = static_cast<ITextProcessorInfo*>(this);
            AddRef();
            return NOERROR;
        }
        return InterfacedObject::queryInterface(iid, ppv);
    }

    UNKNOWN_INTERFACE_IMPLEMENTATION
};

#endif // TEXTPROCESSORINFO_H
