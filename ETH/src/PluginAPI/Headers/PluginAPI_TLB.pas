unit PluginAPI_TLB;

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
// File generated on 24.07.2016 19:12:56 from Type Library described below.

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
//   tlibimp  PluginAPI.tlb -P -Pt+ -C
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Winapi.ActiveX;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  PluginAPIMajorVersion = 1;
  PluginAPIMinorVersion = 0;

  LIBID_PluginAPI: TGUID = '{814E475D-CAE7-45CF-98B2-801F1FE65EB7}';

  IID_ITextEvents: TGUID = '{2BD15A8F-3DFB-40B3-8440-351B08153202}';
  IID_ITextProcessor: TGUID = '{51655D3B-FF05-4615-A92C-9915277BF8E6}';
  IID_ITextProcessorFactory: TGUID = '{53328BD4-D477-4C7D-8601-B9353BDAFF43}';
  IID_ITextProcessorRegistry: TGUID = '{841054BC-8F13-4FC9-BD4A-3447A655DA3F}';
  IID_ITextProcessorInfo: TGUID = '{3D3CB57B-C9C1-4814-9612-76A9AF7425B1}';
  IID_IApplicationWindows: TGUID = '{A8E4AE29-27A3-487B-8E6F-6109DAFBA8C1}';
  IID_ISettings: TGUID = '{AF64592F-D6CF-4A5B-8A1B-64979275A826}';
  IID_IApplicationCore: TGUID = '{47EC281A-C1C0-43A6-AA2C-74CD26639831}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ITextEvents = interface;
  ITextProcessor = interface;
  ITextProcessorFactory = interface;
  ITextProcessorRegistry = interface;
  ITextProcessorInfo = interface;
  IApplicationWindows = interface;
  ISettings = interface;
  IApplicationCore = interface;

// *********************************************************************//
// Interface: ITextEvents
// Flags:     (0)
// GUID:      {2BD15A8F-3DFB-40B3-8440-351B08153202}
// *********************************************************************//
  ITextEvents = interface(IUnknown)
    ['{2BD15A8F-3DFB-40B3-8440-351B08153202}']
    procedure OnNewText(const Text: WideString); safecall;
  end;

// *********************************************************************//
// Interface: ITextProcessor
// Flags:     (0)
// GUID:      {51655D3B-FF05-4615-A92C-9915277BF8E6}
// *********************************************************************//
  ITextProcessor = interface(IUnknown)
    ['{51655D3B-FF05-4615-A92C-9915277BF8E6}']
    procedure SetTextReceiver(const Reciever: ITextEvents); safecall;
    procedure HideSettingsWindow; safecall;
    procedure ShowSettingsWindow; safecall;
  end;

// *********************************************************************//
// Interface: ITextProcessorFactory
// Flags:     (0)
// GUID:      {53328BD4-D477-4C7D-8601-B9353BDAFF43}
// *********************************************************************//
  ITextProcessorFactory = interface(IUnknown)
    ['{53328BD4-D477-4C7D-8601-B9353BDAFF43}']
    function GetNewTextProcessor(const ApplicationCore: IApplicationCore): ITextProcessor; safecall;
  end;

// *********************************************************************//
// Interface: ITextProcessorRegistry
// Flags:     (0)
// GUID:      {841054BC-8F13-4FC9-BD4A-3447A655DA3F}
// *********************************************************************//
  ITextProcessorRegistry = interface(IUnknown)
    ['{841054BC-8F13-4FC9-BD4A-3447A655DA3F}']
    procedure RegisterFactory(const Factory: ITextProcessorFactory; const Info: ITextProcessorInfo); safecall;
  end;

// *********************************************************************//
// Interface: ITextProcessorInfo
// Flags:     (0)
// GUID:      {3D3CB57B-C9C1-4814-9612-76A9AF7425B1}
// *********************************************************************//
  ITextProcessorInfo = interface(IUnknown)
    ['{3D3CB57B-C9C1-4814-9612-76A9AF7425B1}']
    function Get_Name: WideString; safecall;
    function Get_ID: TGUID; safecall;
    function Get_Version: WideString; safecall;
    property Name: WideString read Get_Name;
    property ID: TGUID read Get_ID;
    property Version: WideString read Get_Version;
  end;

// *********************************************************************//
// Interface: IApplicationWindows
// Flags:     (0)
// GUID:      {A8E4AE29-27A3-487B-8E6F-6109DAFBA8C1}
// *********************************************************************//
  IApplicationWindows = interface(IUnknown)
    ['{A8E4AE29-27A3-487B-8E6F-6109DAFBA8C1}']
    function Get_ApplicationWnd: Integer; safecall;
    function Get_MainWnd: Integer; safecall;
    function Get_HostWnd: Integer; safecall;
    property ApplicationWnd: Integer read Get_ApplicationWnd;
    property MainWnd: Integer read Get_MainWnd;
    property HostWnd: Integer read Get_HostWnd;
  end;

// *********************************************************************//
// Interface: ISettings
// Flags:     (0)
// GUID:      {AF64592F-D6CF-4A5B-8A1B-64979275A826}
// *********************************************************************//
  ISettings = interface(IUnknown)
    ['{AF64592F-D6CF-4A5B-8A1B-64979275A826}']
    procedure WriteString(const Name: WideString; const Value: WideString); safecall;
    function ReadString(const Name: WideString; const Default: WideString): WideString; safecall;
    procedure WriteInteger(const Name: WideString; Value: SYSINT); safecall;
    function ReadInteger(const Name: WideString; Default: SYSINT): SYSINT; safecall;
    procedure WriteBoolean(const Name: WideString; Value: WordBool); safecall;
    function ReadBoolean(const Name: WideString; Default: WordBool): WordBool; safecall;
  end;

// *********************************************************************//
// Interface: IApplicationCore
// Flags:     (0)
// GUID:      {47EC281A-C1C0-43A6-AA2C-74CD26639831}
// *********************************************************************//
  IApplicationCore = interface(IUnknown)
    ['{47EC281A-C1C0-43A6-AA2C-74CD26639831}']
    function Get_ApplicationWindows: IApplicationWindows; safecall;
    function Get_Settings: ISettings; safecall;
    property ApplicationWindows: IApplicationWindows read Get_ApplicationWindows;
    property Settings: ISettings read Get_Settings;
  end;

implementation

uses System.Win.ComObj;

end.
