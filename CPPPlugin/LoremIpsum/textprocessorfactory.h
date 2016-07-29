#ifndef TEXTPROCESSORFACTORY_H
#define TEXTPROCESSORFACTORY_H

#include "PluginAPI/PluginAPI_TLB.h"
#include "interfacedobject.h"
#include "qdebug.h"

class TextProcessorFactory : public ITextProcessorFactory, InterfacedObject
{
public:
    HRESULT STDMETHODCALLTYPE GetNewTextProcessor(IApplicationCore* ApplicationCore,
                                                  ITextProcessor** Value);

    HRESULT queryInterface(const IID &iid, void **ppv)
    {
        if (iid == IID_ITextProcessorFactory) {
            *ppv = static_cast<ITextProcessorFactory*>(this);
            AddRef();
            return NOERROR;
        }
        return InterfacedObject::queryInterface(iid, ppv);
    }

    UNKNOWN_INTERFACE_IMPLEMENTATION
};

#endif // TEXTPROCESSORFACTORY_H
