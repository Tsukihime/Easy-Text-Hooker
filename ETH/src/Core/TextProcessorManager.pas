unit TextProcessorManager;

interface

uses
  PluginAPI_TLB,
  TextProcessorNode,
  TextProcessorProvider,
  JSON,
  System.Generics.Collections;

type
  TTextProcessorManager = class
  private
    FTextProcessorTree: TTextProcessorNode;
    FApplicationWindows: IApplicationWindows;
    FTextProcessorProvider: ITextProcessorProvider;
    function SaveNode(const Node: TTextProcessorNode): TJSONObject;
    function LoadNode(const NodeConfig: TJSONObject): TTextProcessorNode;
    function NewTextProcessorNode(const ProcessorID: TGUID;
      jNodeSettings: TJSONObject): TTextProcessorNode; overload;
  public
    function NewTextProcessorNode(const ProcessorID: TGUID)
      : TTextProcessorNode; overload;
    procedure GetAvailableTextProcessors(List: TList<ITextProcessorInfo>);

    procedure UnloadTreeAndSave(Config: TJSONObject);
    procedure LoadTree(Config: TJSONObject);
  public
    constructor Create(const ApplicationWindows: IApplicationWindows);
    destructor Destroy; override;
    property TextProcessorTree: TTextProcessorNode read FTextProcessorTree;
  end;

implementation

uses
  SettingsNode,
  ApplicationCore,
  SysUtils;

{ TTextProcessorManager }

constructor TTextProcessorManager.Create(const ApplicationWindows
  : IApplicationWindows);
begin
  FApplicationWindows := ApplicationWindows;
  FTextProcessorProvider := TTextProcessorProvider.Create;
  FTextProcessorTree := TTextProcessorNode.CreateRoot;
end;

destructor TTextProcessorManager.Destroy;
begin
  FTextProcessorTree.Free;
  inherited;
end;

procedure TTextProcessorManager.GetAvailableTextProcessors
  (List: TList<ITextProcessorInfo>);
var
  i: Integer;
begin
  for i := 0 to FTextProcessorProvider.Count - 1 do
    List.Add(FTextProcessorProvider.Items[i].Info);
end;

function TTextProcessorManager.NewTextProcessorNode(const ProcessorID: TGUID)
  : TTextProcessorNode;
begin
  Result := NewTextProcessorNode(ProcessorID, nil);
end;

function TTextProcessorManager.NewTextProcessorNode(const ProcessorID: TGUID;
  jNodeSettings: TJSONObject): TTextProcessorNode;
var
  Item: ITextProcessorListItem;
  TextProcessor: ITextProcessor;
  ApplicationCore: IApplicationCore;
  TextProcessorSettings: TSettingsNode;
begin
  Item := FTextProcessorProvider.GetItemByID(ProcessorID);
  if Assigned(Item) then
  begin
    TextProcessorSettings := TSettingsNode.Create(jNodeSettings);

    ApplicationCore := TApplicationCore.Create(FApplicationWindows,
      TextProcessorSettings);

    TextProcessor := Item.Factory.GetNewTextProcessor(ApplicationCore);

    Result := TTextProcessorNode.Create(TextProcessor, Item.Info,
      TextProcessorSettings);
  end
  else
    Result := nil;
end;

function TTextProcessorManager.SaveNode(const Node: TTextProcessorNode)
  : TJSONObject;
var
  NodeObj: TJSONObject;
  NodeChilds: TJSONArray;
  i: Integer;
begin
  NodeObj := TJSONObject.Create;

  NodeObj.AddPair('Name', Node.Info.Name);
  NodeObj.AddPair('ID', GUIDToString(Node.Info.ID));
  NodeObj.AddPair('Data', Node.Settings.Serialized);

  NodeChilds := TJSONArray.Create;

  for i := 0 to Node.ChildCount - 1 do
    NodeChilds.Add(SaveNode(Node.Childs[i]));

  NodeObj.AddPair('Childs', NodeChilds);

  Result := NodeObj;
end;

procedure TTextProcessorManager.UnloadTreeAndSave(Config: TJSONObject);
var
  jNodes: TJSONArray;
  Node: TTextProcessorNode;
  i: Integer;
begin
  TextProcessorTree.IterateSubtree( // unload all TextProcessor instances
    procedure(ANode: TTextProcessorNode; var Done: Boolean)
    begin
      ANode.Unload;
    end);

  jNodes := TJSONArray.Create;
  for i := 0 to TextProcessorTree.ChildCount - 1 do
    jNodes.Add(SaveNode(TextProcessorTree.Childs[i]));

  Config.RemovePair('TextProcessorTree');
  Config.AddPair('TextProcessorTree', jNodes);

  while TextProcessorTree.ChildCount > 0 do
  begin
    Node := TextProcessorTree.Childs[0];
    TextProcessorTree.RemoveChild(Node);
  end;
end;

function TTextProcessorManager.LoadNode(const NodeConfig: TJSONObject)
  : TTextProcessorNode;
var
  ProcessorID: TGUID;
  jValue: TJSONValue;
  ChildNode: TTextProcessorNode;
begin
  Result := nil;

  jValue := NodeConfig.GetValue('ID');
  if not(Assigned(jValue) and (jValue is TJSONString)) then
    exit;

  try
    ProcessorID := StringToGUID((jValue as TJSONString).Value);
  except
    on E: EConvertError do
      exit;
  end;

  jValue := NodeConfig.GetValue('Data');
  if not(Assigned(jValue) and (jValue is TJSONObject)) then
    exit;

  Result := NewTextProcessorNode(ProcessorID, jValue as TJSONObject);
  if not Assigned(Result) then
    exit;

  // load childs
  jValue := NodeConfig.GetValue('Childs');
  if not(Assigned(jValue) and (jValue is TJSONArray)) then
    exit;

  for jValue in (jValue as TJSONArray) do
    if jValue is TJSONObject then
    begin
      ChildNode := LoadNode(jValue as TJSONObject);
      if Assigned(ChildNode) then
        Result.InsertTextProcessorNode(ChildNode);
    end;
end;

procedure TTextProcessorManager.LoadTree(Config: TJSONObject);
var
  jValue: TJSONValue;
  jNodes: TJSONArray;
  Node: TTextProcessorNode;
begin
  jValue := Config.GetValue('TextProcessorTree');

  if not(Assigned(jValue) and (jValue is TJSONArray)) then
    exit;

  jNodes := jValue as TJSONArray;
  for jValue in jNodes do
    if jValue is TJSONObject then
    begin
      Node := LoadNode(jValue as TJSONObject);
      FTextProcessorTree.InsertTextProcessorNode(Node);
    end;
end;

end.
