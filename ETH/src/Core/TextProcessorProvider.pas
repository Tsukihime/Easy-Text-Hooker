unit TextProcessorProvider;

interface

uses
  PluginAPI_TLB,
  PluginManager,
  System.Generics.Collections,
  Classes;

type
  ITextProcessorListItem = interface
    function GetFactory: ITextProcessorFactory;
    function GetInfo: ITextProcessorInfo;
    // props
    property Info: ITextProcessorInfo read GetInfo;
    property Factory: ITextProcessorFactory read GetFactory;
  end;

  ITextProcessorProvider = interface
    function GetCount: Integer;
    function GetItem(const Index: Integer): ITextProcessorListItem;
    function GetItemByID(const ID: TGUID): ITextProcessorListItem;
    // props
    property Count: Integer read GetCount;
    property Items[const Index: Integer]: ITextProcessorListItem
      read GetItem; default;
  end;

  TTextProcessorListItem = class(TInterfacedObject, ITextProcessorListItem)
  private
    FFactory: ITextProcessorFactory;
    FInfo: ITextProcessorInfo;
    function GetFactory: ITextProcessorFactory;
    function GetInfo: ITextProcessorInfo;
  public
    constructor Create(const AFactory: ITextProcessorFactory;
      const Info: ITextProcessorInfo);
    property Info: ITextProcessorInfo read GetInfo;
    property Factory: ITextProcessorFactory read GetFactory;
  end;

  TTextProcessorProvider = class(TInterfacedObject, ITextProcessorRegistry,
    ITextProcessorProvider)
  private
    FPluginManager: TPluginManager;
    FTextProcessorPlugins: TList<ITextProcessorListItem>;
    function GetCount: Integer;
    function GetItem(const Index: Integer): ITextProcessorListItem;
    procedure RegisterFactory(const Factory: ITextProcessorFactory;
      const Info: ITextProcessorInfo); safecall;
  public
    constructor Create;
    destructor Destroy; override;
    function GetItemByID(const ID: TGUID): ITextProcessorListItem; overload;

    property Count: Integer read GetCount;
    property Items[const Index: Integer]: ITextProcessorListItem
      read GetItem; default;
  end;

procedure ETHInitializeTextProcessors(const Registry: ITextProcessorRegistry);
  stdcall; external 'InternalPlugins.dll';

procedure ETHFinalize; stdcall; external 'InternalPlugins.dll';

implementation

uses
  SysUtils,
  Forms;

{ TTextProcessorProvider }

constructor TTextProcessorProvider.Create;
begin
  FTextProcessorPlugins := TList<ITextProcessorListItem>.Create;
  ETHInitializeTextProcessors(self);
  FPluginManager := TPluginManager.Create('.', true);
  try
    FPluginManager.RegisterAll(self);
  except
    on e: Exception do
      Application.HandleException(e);
  end;
end;

destructor TTextProcessorProvider.Destroy;
begin
  ETHFinalize;
  FTextProcessorPlugins.Free;
  FPluginManager.Free;
  inherited;
end;

function TTextProcessorProvider.GetCount: Integer;
begin
  Result := FTextProcessorPlugins.Count;
end;

function TTextProcessorProvider.GetItemByID(const ID: TGUID)
  : ITextProcessorListItem;
var
  Item: ITextProcessorListItem;
begin
  Result := nil;
  for Item in FTextProcessorPlugins do
    if Item.Info.ID = ID then
    begin
      Result := Item;
      break;
    end;
end;

function TTextProcessorProvider.GetItem(const Index: Integer)
  : ITextProcessorListItem;
begin
  Result := FTextProcessorPlugins[Index];
end;

procedure TTextProcessorProvider.RegisterFactory(const Factory
  : ITextProcessorFactory; const Info: ITextProcessorInfo);
begin
  FTextProcessorPlugins.Add(TTextProcessorListItem.Create(Factory, Info));
end;

{ TPluginListItem }

constructor TTextProcessorListItem.Create(const AFactory: ITextProcessorFactory;
  const Info: ITextProcessorInfo);
begin
  FFactory := AFactory;
  FInfo := Info;
end;

function TTextProcessorListItem.GetFactory: ITextProcessorFactory;
begin
  Result := FFactory;
end;

function TTextProcessorListItem.GetInfo: ITextProcessorInfo;
begin
  Result := FInfo;
end;

end.
