#include "textprocessorfactory.h"
#include "textprocessor.h"

HRESULT STDMETHODCALLTYPE TextProcessorFactory::GetNewTextProcessor(IApplicationCore* ApplicationCore,
                                                                    ITextProcessor** Value)
{
    TextProcessor* TextProc = new TextProcessor(ApplicationCore);
    TextProc->QueryInterface(IID_ITextProcessor, reinterpret_cast<void**>(Value));
    return S_OK;
}
