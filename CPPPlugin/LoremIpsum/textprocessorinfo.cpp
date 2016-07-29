#include "textprocessorinfo.h"

HRESULT STDMETHODCALLTYPE TextProcessorInfo::get_Name(BSTR* Value)
{
    *Value = SysAllocString(L"Lorem Ipsum Qt Plugin");
    return S_OK;
}

HRESULT STDMETHODCALLTYPE TextProcessorInfo::get_ID(GUID* Value)
{
    *Value = {0x00000007, 0x0007, 0x0007,{ 0x07, 0x07, 0x07,0x07, 0x07, 0x07,0x07, 0x07} };
    return S_OK;
}

HRESULT STDMETHODCALLTYPE TextProcessorInfo::get_Version(BSTR* Value)
{
    *Value = SysAllocString(L"0.1");
    return S_OK;
}
