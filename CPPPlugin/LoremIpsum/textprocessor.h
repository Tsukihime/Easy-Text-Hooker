#ifndef TEXTPROCESSOR_H
#define TEXTPROCESSOR_H

#include "PluginAPI/PluginAPI_TLB.h"
#include "interfacedobject.h"
#include <QTimer>

#include "settingsform.h"

class TextProcessor : public ITextProcessor, InterfacedObject
{
public:
    TextProcessor(IApplicationCore* ApplicationCore);
    ~TextProcessor();

    void OnTimerUpdate();

    HRESULT STDMETHODCALLTYPE SetTextReceiver(ITextEvents* Reciever);
    HRESULT STDMETHODCALLTYPE HideSettingsWindow(void);
    HRESULT STDMETHODCALLTYPE ShowSettingsWindow(void);

    HRESULT queryInterface(const IID &iid, void **ppv)
    {
        if (iid == IID_ITextProcessor) {
            *ppv = static_cast<ITextProcessor*>(this);
            AddRef();
            return NOERROR;
        }
        return InterfacedObject::queryInterface(iid, ppv);
    }

    UNKNOWN_INTERFACE_IMPLEMENTATION
private:
    QTimer* timer;
    SettingsForm* settingsForm;
    ITextEvents* Reciever = nullptr;
    IApplicationCore* ApplicationCore = nullptr;
    int Iteration = 0;
};

#endif // TEXTPROCESSOR_H
