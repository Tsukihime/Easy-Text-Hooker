unit TextProcessorNode;

interface

uses
  PluginAPI_TLB,
  SettingsNode,
  TextPublisher,
  System.Generics.Collections;

type
  TTextProcessorNode = class;
  TIterateSubtreeRef = reference to procedure(ANode: TTextProcessorNode;
    var Done: Boolean);

  TTextProcessorNode = class
  protected
    FTextProcessor: ITextProcessor;
    FPublisher: IPublisher;
    FTextProcessorSettings: ISerialisable;
    FInfo: ITextProcessorInfo;
    //
    FParent: TTextProcessorNode;
    FChilds: TObjectList<TTextProcessorNode>;
  protected
    function GetRoot: TTextProcessorNode;
    function GetChildCount: Integer;
    function GetChild(const Index: Integer): TTextProcessorNode;

    function AddChild(const ANode: TTextProcessorNode)
      : TTextProcessorNode; overload;
    function ExtractChild(const ANode: TTextProcessorNode): TTextProcessorNode;
    procedure IterateSubtreeDone(AProc: TIterateSubtreeRef; var Done: Boolean);
  public
    function InsertTextProcessorNode(const ATextProcessorNode
      : TTextProcessorNode): TTextProcessorNode;
    procedure MoveTo(const ANewParent: TTextProcessorNode);
    procedure RemoveChild(const AChild: TTextProcessorNode);
    procedure Remove;

    procedure IterateSubtree(AProc: TIterateSubtreeRef);

    procedure ShowTextProcessorGUI;
    procedure HideTextProcessorGUI;

    property Root: TTextProcessorNode read GetRoot;
    property Parent: TTextProcessorNode read FParent;
    property ChildCount: Integer read GetChildCount;
    property Childs[const Index: Integer]: TTextProcessorNode read GetChild;

    function IsAncestorOf(const DescendantCandidate
      : TTextProcessorNode): Boolean;
    function IsRoot: Boolean;

    property Settings: ISerialisable read FTextProcessorSettings;
    property Info: ITextProcessorInfo read FInfo;

    procedure Unload;
  public
    constructor CreateRoot;
    constructor Create(const ATextProcessor: ITextProcessor;
      const AInfo: ITextProcessorInfo;
      const TextProcessorSettings: ISerialisable);
    destructor Destroy; override;
  end;

implementation

{ TTextProcessorNode }

constructor TTextProcessorNode.Create(const ATextProcessor: ITextProcessor;
  const AInfo: ITextProcessorInfo; const TextProcessorSettings: ISerialisable);
var
  TextEventsBroadcaster: TTextEventsBroadcaster;
begin
  FInfo := AInfo;
  FTextProcessor := ATextProcessor;
  FTextProcessorSettings := TextProcessorSettings;
  TextEventsBroadcaster := TTextEventsBroadcaster.Create;
  FTextProcessor.SetTextReceiver(TextEventsBroadcaster);
  FPublisher := TextEventsBroadcaster;

  FChilds := TObjectList<TTextProcessorNode>.Create;
end;

constructor TTextProcessorNode.CreateRoot;
begin
  FInfo := nil;
  FTextProcessor := nil;
  FPublisher := nil;
  FChilds := TObjectList<TTextProcessorNode>.Create;
end;

destructor TTextProcessorNode.Destroy;
begin
  FChilds.Free;
  inherited;
end;

function TTextProcessorNode.GetRoot: TTextProcessorNode;
begin
  if Assigned(FParent) then
    Result := FParent.GetRoot
  else
    Result := self;
end;

function TTextProcessorNode.GetChildCount: Integer;
begin
  Result := FChilds.Count;
end;

function TTextProcessorNode.GetChild(const Index: Integer): TTextProcessorNode;
begin
  Result := FChilds[Index];
end;

function TTextProcessorNode.AddChild(const ANode: TTextProcessorNode)
  : TTextProcessorNode;
begin
  ANode.FParent := self;
  FChilds.Add(ANode);
  if Assigned(FPublisher) then
    FPublisher.Subscribe(ANode.FTextProcessor);
  Result := ANode;
end;

function TTextProcessorNode.InsertTextProcessorNode(const ATextProcessorNode
  : TTextProcessorNode): TTextProcessorNode;
begin
  Result := AddChild(ATextProcessorNode);
end;

function TTextProcessorNode.ExtractChild(const ANode: TTextProcessorNode)
  : TTextProcessorNode;
begin
  Result := FChilds.Extract(ANode);
  if Assigned(Result) then
  begin
    Result.FParent := nil;
    if Assigned(FPublisher) then
      FPublisher.Unsubscribe(Result.FTextProcessor);
  end;
end;

procedure TTextProcessorNode.Remove;
begin
  if Assigned(FParent) then
    FParent.RemoveChild(self)
  else
    Free;
end;

procedure TTextProcessorNode.RemoveChild(const AChild: TTextProcessorNode);
var
  extracted: TTextProcessorNode;
begin
  extracted := ExtractChild(AChild);
  if Assigned(extracted) then
    extracted.Free;
end;

procedure TTextProcessorNode.ShowTextProcessorGUI;
begin
  FTextProcessor.ShowSettingsWindow;
end;

procedure TTextProcessorNode.Unload;
begin
  if not IsRoot and Assigned(Parent.FPublisher) then
    Parent.FPublisher.Unsubscribe(FTextProcessor);
  FTextProcessor := nil;
  FPublisher := nil;
end;

procedure TTextProcessorNode.HideTextProcessorGUI;
begin
  FTextProcessor.HideSettingsWindow;
end;

procedure TTextProcessorNode.MoveTo(const ANewParent: TTextProcessorNode);
var
  SameNode: Boolean;
begin
  SameNode := (ANewParent = FParent);
  if SameNode or IsAncestorOf(ANewParent) then
    exit;

  if Assigned(FParent) then
    FParent.ExtractChild(self);
  ANewParent.AddChild(self);
end;

function TTextProcessorNode.IsAncestorOf(const DescendantCandidate
  : TTextProcessorNode): Boolean;
var
  Child: TTextProcessorNode;
begin
  Result := false;
  for Child in FChilds do
  begin
    Result := (Child = DescendantCandidate);
    if Result then
      break;

    Result := Child.IsAncestorOf(DescendantCandidate);
    if Result then
      break;
  end;
end;

function TTextProcessorNode.IsRoot: Boolean;
begin
  Result := (self = Root);
end;

procedure TTextProcessorNode.IterateSubtree(AProc: TIterateSubtreeRef);
var
  Done: Boolean;
begin
  Done := false;
  IterateSubtreeDone(AProc, Done);
end;

procedure TTextProcessorNode.IterateSubtreeDone(AProc: TIterateSubtreeRef;
  var Done: Boolean);
var
  Child: TTextProcessorNode;
begin
  AProc(self, Done);
  if Done then
    exit;

  for Child in FChilds do
  begin
    Child.IterateSubtreeDone(AProc, Done);
    if Done then
      break;
  end;
end;

end.
