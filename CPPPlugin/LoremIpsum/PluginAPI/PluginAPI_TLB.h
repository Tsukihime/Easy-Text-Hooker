// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 52393 $
// File generated on 24.07.2016 13:02:58 from Type Library described below.

// ************************************************************************  //
// Type Lib: PluginAPI.tlb (1)
// LIBID: {814E475D-CAE7-45CF-98B2-801F1FE65EB7}
// LCID: 0
// Helpfile: 
// HelpString: Easy Text Hooket Plugin Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// Cmdline:
//   tlibimp  PluginAPI.tlb -P -C -Pt+ -I
// manually edited!
// ************************************************************************ //
#ifndef   PluginAPI_TLBH
#define   PluginAPI_TLBH

#include <olectl.h>
#include <ocidl.h>

namespace Pluginapi_tlb
{

// *********************************************************************//
// HelpString: Easy Text Hooket Plugin Type Library
// Version:    1.0
// *********************************************************************//


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLSID_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
extern const GUID LIBID_PluginAPI;
extern const GUID IID_ITextEvents;
extern const GUID IID_ITextProcessor;
extern const GUID IID_ITextProcessorFactory;
extern const GUID IID_ITextProcessorRegistry;
extern const GUID IID_ITextProcessorInfo;
extern const GUID IID_IApplicationWindows;
extern const GUID IID_ISettings;
extern const GUID IID_IApplicationCore;

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//

interface DECLSPEC_UUID("{2BD15A8F-3DFB-40B3-8440-351B08153202}") ITextEvents;
//typedef TComInterface<ITextEvents, &IID_ITextEvents> ITextEventsPtr;

interface DECLSPEC_UUID("{51655D3B-FF05-4615-A92C-9915277BF8E6}") ITextProcessor;
//typedef TComInterface<ITextProcessor, &IID_ITextProcessor> ITextProcessorPtr;

interface DECLSPEC_UUID("{53328BD4-D477-4C7D-8601-B9353BDAFF43}") ITextProcessorFactory;
//typedef TComInterface<ITextProcessorFactory, &IID_ITextProcessorFactory> ITextProcessorFactoryPtr;

interface DECLSPEC_UUID("{841054BC-8F13-4FC9-BD4A-3447A655DA3F}") ITextProcessorRegistry;
//typedef TComInterface<ITextProcessorRegistry, &IID_ITextProcessorRegistry> ITextProcessorRegistryPtr;

interface DECLSPEC_UUID("{3D3CB57B-C9C1-4814-9612-76A9AF7425B1}") ITextProcessorInfo;
//typedef TComInterface<ITextProcessorInfo, &IID_ITextProcessorInfo> ITextProcessorInfoPtr;

interface DECLSPEC_UUID("{A8E4AE29-27A3-487B-8E6F-6109DAFBA8C1}") IApplicationWindows;
//typedef TComInterface<IApplicationWindows, &IID_IApplicationWindows> IApplicationWindowsPtr;

interface DECLSPEC_UUID("{AF64592F-D6CF-4A5B-8A1B-64979275A826}") ISettings;
//typedef TComInterface<ISettings, &IID_ISettings> ISettingsPtr;

interface DECLSPEC_UUID("{47EC281A-C1C0-43A6-AA2C-74CD26639831}") IApplicationCore;
//typedef TComInterface<IApplicationCore, &IID_IApplicationCore> IApplicationCorePtr;

// *********************************************************************//
// Interface: ITextEvents
// Flags:     (0)
// GUID:      {2BD15A8F-3DFB-40B3-8440-351B08153202}
// *********************************************************************//
interface ITextEvents  : public IUnknown
{
public:
  virtual HRESULT STDMETHODCALLTYPE OnNewText(BSTR Text/*[in]*/) = 0; // [-1]
};

// *********************************************************************//
// Interface: ITextProcessor
// Flags:     (0)
// GUID:      {51655D3B-FF05-4615-A92C-9915277BF8E6}
// *********************************************************************//
interface ITextProcessor  : public IUnknown
{
public:
  virtual HRESULT STDMETHODCALLTYPE SetTextReceiver(Pluginapi_tlb::ITextEvents* Reciever/*[in]*/) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE HideSettingsWindow(void) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE ShowSettingsWindow(void) = 0; // [-1]
};

// *********************************************************************//
// Interface: ITextProcessorFactory
// Flags:     (0)
// GUID:      {53328BD4-D477-4C7D-8601-B9353BDAFF43}
// *********************************************************************//
interface ITextProcessorFactory  : public IUnknown
{
public:
  virtual HRESULT STDMETHODCALLTYPE GetNewTextProcessor(Pluginapi_tlb::IApplicationCore* ApplicationCore/*[in]*/,
														Pluginapi_tlb::ITextProcessor** Value/*[out,retval]*/) = 0; // [-1]
};

// *********************************************************************//
// Interface: ITextProcessorRegistry
// Flags:     (0)
// GUID:      {841054BC-8F13-4FC9-BD4A-3447A655DA3F}
// *********************************************************************//
interface ITextProcessorRegistry  : public IUnknown
{
public:
  virtual HRESULT STDMETHODCALLTYPE RegisterFactory(Pluginapi_tlb::ITextProcessorFactory* Factory/*[in]*/,
													Pluginapi_tlb::ITextProcessorInfo* Info/*[in]*/) = 0; // [-1]
};

// *********************************************************************//
// Interface: ITextProcessorInfo
// Flags:     (0)
// GUID:      {3D3CB57B-C9C1-4814-9612-76A9AF7425B1}
// *********************************************************************//
interface ITextProcessorInfo  : public IUnknown
{
public:
  virtual HRESULT STDMETHODCALLTYPE get_Name(BSTR* Value/*[out,retval]*/) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE get_ID(GUID* Value/*[out,retval]*/) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE get_Version(BSTR* Value/*[out,retval]*/) = 0; // [-1]
};

// *********************************************************************//
// Interface: IApplicationWindows
// Flags:     (0)
// GUID:      {A8E4AE29-27A3-487B-8E6F-6109DAFBA8C1}
// *********************************************************************//
interface IApplicationWindows  : public IUnknown
{
public:
  virtual HRESULT STDMETHODCALLTYPE get_ApplicationWnd(long* Value/*[out,retval]*/) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE get_MainWnd(long* Value/*[out,retval]*/) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE get_HostWnd(long* Value/*[out,retval]*/) = 0; // [-1]
};

// *********************************************************************//
// Interface: ISettings
// Flags:     (0)
// GUID:      {AF64592F-D6CF-4A5B-8A1B-64979275A826}
// *********************************************************************//
interface ISettings  : public IUnknown
{
public:
  virtual HRESULT STDMETHODCALLTYPE WriteString(BSTR Name/*[in]*/, BSTR Value/*[in]*/) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE ReadString(BSTR Name/*[in]*/, BSTR Default/*[in]*/,
											   BSTR* Value/*[out,retval]*/) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE WriteInteger(BSTR Name/*[in]*/, int Value/*[in]*/) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE ReadInteger(BSTR Name/*[in]*/, int Default/*[in]*/,
												int* Value/*[out,retval]*/) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE WriteBoolean(BSTR Name/*[in]*/, VARIANT_BOOL Value/*[in]*/) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE ReadBoolean(BSTR Name/*[in]*/, VARIANT_BOOL Default/*[in]*/,
												VARIANT_BOOL* Value/*[out,retval]*/) = 0; // [-1]
};

// *********************************************************************//
// Interface: IApplicationCore
// Flags:     (0)
// GUID:      {47EC281A-C1C0-43A6-AA2C-74CD26639831}
// *********************************************************************//
interface IApplicationCore  : public IUnknown
{
public:
  virtual HRESULT STDMETHODCALLTYPE get_ApplicationWindows(Pluginapi_tlb::IApplicationWindows** Value/*[out,retval]*/) = 0; // [-1]
  virtual HRESULT STDMETHODCALLTYPE get_Settings(Pluginapi_tlb::ISettings** Value/*[out,retval]*/) = 0; // [-1]
};


}     // namespace Pluginapi_tlb

#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using  namespace Pluginapi_tlb;
#endif

#endif // PluginAPI_TLBH
