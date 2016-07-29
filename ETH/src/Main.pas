unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, VirtualTrees, Vcl.Forms, Vcl.Menus, Vcl.ImgList, Vcl.Controls,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Graphics,
  //
  ActiveX,
  PluginAPI_TLB,
  TextProcessorManager,
  TextProcessorNode,
  TextProcessorProvider,
  SettingsFile,
  System.Generics.Collections,
  HostPluginUIPanel;

type
  TMainForm = class(TForm)
    HostPanelStub: TPanel;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    DeleteMenuItem: TMenuItem;
    FilterGraphTree: TVirtualStringTree;
    Splitter1: TSplitter;
    Timer1: TTimer;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DeleteMenuItemClick(Sender: TObject);
    procedure AddMenuItemClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure FilterGraphTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure FilterGraphTreeGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure FilterGraphTreeDragAllowed(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure FilterGraphTreeDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure FilterGraphTreeDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure FilterGraphTreeAddToSelection(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure FilterGraphTreeAfterItemPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect);
  private
    HostPanel: THostPlugunUIPanel;
    TextProcessorManager: TTextProcessorManager;
    SettingsFile: TSettingsFile;
    procedure UpdateTree;
    procedure AddItemsToTree(TextProcessorNode: TTextProcessorNode;
      AParentVisualNode: PVirtualNode = nil);
    function GetSelectedGraphNode: PVirtualNode;
    function GetSelectedGraphNodeData: TTextProcessorNode;
    function IsDescendantNode(AVirtualTree: TBaseVirtualTree;
      Ancestor, DescendantCandidate: PVirtualNode): Boolean;
  public
    { Public declarations }
  end;

  PTextProcessorNode = ^TTextProcessorNode;

type
  TIterateData = record
    Ancestor, DescendantCandidate: PVirtualNode;
    IsDescendant: Boolean;
  end;

  PIterateData = ^TIterateData;

var
  MainForm: TMainForm;

implementation

uses
  JSON,
  ApplicationCore;

{$R *.dfm}

procedure TMainForm.FilterGraphTreeAddToSelection(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  NodeData: PTextProcessorNode;
begin
  NodeData := Sender.GetNodeData(Node);

  NodeData^.Root.IterateSubtree( // Hide All Gui's
    procedure(ANode: TTextProcessorNode; var Done: Boolean)
    begin
      if ANode <> ANode.Root then
        ANode.HideTextProcessorGUI;
    end);

  NodeData^.ShowTextProcessorGUI;
  HostPanel.Resize;
end;

procedure TMainForm.FilterGraphTreeAfterItemPaint(Sender: TBaseVirtualTree;
TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect);
var
  Level: Integer;
  x: Integer;
begin
  Level := Sender.GetNodeLevel(Node);
  if Level = 0 then
    exit;

  TargetCanvas.Pen.Color := TVirtualStringTree(Sender).Colors.TreeLineColor;

  x := Level * TVirtualStringTree(Sender).Indent;
  TargetCanvas.MoveTo(x, ItemRect.CenterPoint.Y - 3);
  TargetCanvas.LineTo(x + 4, ItemRect.CenterPoint.Y + 1);

  TargetCanvas.MoveTo(x, ItemRect.CenterPoint.Y + 3);
  TargetCanvas.LineTo(x + 4, ItemRect.CenterPoint.Y - 1);

  TargetCanvas.MoveTo(x, ItemRect.CenterPoint.Y);
  TargetCanvas.LineTo(x + 4, ItemRect.CenterPoint.Y);
end;

procedure TMainForm.FilterGraphTreeDragAllowed(Sender: TBaseVirtualTree;
Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := true;
end;

procedure TMainForm.FilterGraphTreeDragDrop(Sender: TBaseVirtualTree;
Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  pSource, pTarget: PVirtualNode;
  SourceNodeData: PTextProcessorNode;
  TargetNodeData: PTextProcessorNode;
begin
  pSource := TVirtualStringTree(Source).FocusedNode;
  pTarget := Sender.DropTargetNode;

  SourceNodeData := TVirtualStringTree(Source).GetNodeData(pSource);
  TargetNodeData := TVirtualStringTree(Source).GetNodeData(pTarget);
  if Assigned(TargetNodeData) then
    SourceNodeData^.MoveTo(TargetNodeData^)
  else
    SourceNodeData^.MoveTo(TextProcessorManager.TextProcessorTree);

  UpdateTree;
end;

procedure TMainForm.FilterGraphTreeDragOver(Sender: TBaseVirtualTree;
Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
var
  dropNode, dragNode: PVirtualNode;
  IsDescendant, IsSameNode, IsSameTree: Boolean;
begin
  dropNode := Sender.DropTargetNode;
  dragNode := Sender.GetSortedSelection(true)[0];

  IsDescendant := IsDescendantNode(Sender, dragNode, dropNode);
  IsSameNode := (dragNode = dropNode);
  IsSameTree := (Sender = Source);
  Accept := not IsDescendant and not IsSameNode and IsSameTree;
end;

procedure IterateCallback(Sender: TBaseVirtualTree; Node: PVirtualNode;
Data: Pointer; var Abort: Boolean);
begin
  PIterateData(Data).IsDescendant :=
    (PIterateData(Data).DescendantCandidate = Node);
  Abort := PIterateData(Data).IsDescendant;
end;

function TMainForm.IsDescendantNode(AVirtualTree: TBaseVirtualTree;
Ancestor, DescendantCandidate: PVirtualNode): Boolean;
var
  AData: TIterateData;
begin
  AData.Ancestor := Ancestor;
  AData.DescendantCandidate := DescendantCandidate;
  AData.IsDescendant := false;
  AVirtualTree.IterateSubtree(Ancestor, IterateCallback, @AData, []);
  Result := AData.IsDescendant;
end;

procedure TMainForm.FilterGraphTreeGetNodeDataSize(Sender: TBaseVirtualTree;
var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TObject);
end;

procedure TMainForm.FilterGraphTreeGetText(Sender: TBaseVirtualTree;
Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
var CellText: string);
var
  NodeData: PTextProcessorNode;
begin
  NodeData := Sender.GetNodeData(Node);
  if Assigned(NodeData^) then
    CellText := NodeData^.Info.Name
  else
    CellText := 'Not Assighed!';
end;

function TMainForm.GetSelectedGraphNode: PVirtualNode;
var
  Node: PVirtualNode;
begin
  Result := nil;
  for Node in FilterGraphTree.SelectedNodes() do
  begin
    Result := Node;
    break;
  end;
end;

function TMainForm.GetSelectedGraphNodeData: TTextProcessorNode;
var
  Node: PVirtualNode;
  NodeData: PTextProcessorNode;
begin
  Node := GetSelectedGraphNode;
  if Assigned(Node) then
  begin
    NodeData := FilterGraphTree.GetNodeData(Node);
    Result := NodeData^;
  end
  else
    Result := nil;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  MenuItem: TMenuItem;
  i: Integer;
  List: TList<ITextProcessorInfo>;
  AppWindows: IApplicationWindows;
begin
  HostPanel := THostPlugunUIPanel.Create(HostPanelStub);
  HostPanel.Parent := HostPanelStub;

  SettingsFile := TSettingsFile.Create('Config', 'Easy Text Hooker', true);

  AppWindows := TApplicationWindows.Create(Application.Handle, self.Handle,
    HostPanel.Handle);
  TextProcessorManager := TTextProcessorManager.Create(AppWindows);
  TextProcessorManager.LoadTree(SettingsFile.ConfigNode);

  List := TList<ITextProcessorInfo>.Create;
  try
    TextProcessorManager.GetAvailableTextProcessors(List);

    for i := 0 to List.Count - 1 do
    begin
      MenuItem := TMenuItem.Create(PopupMenu1);
      MenuItem.Caption := List[i].Name;
      MenuItem.Tag := i;
      MenuItem.OnClick := AddMenuItemClick;
      MenuItem.ImageIndex := 1;
      PopupMenu1.Items.Add(MenuItem);
    end;
  finally
    List.Free;
  end;

  UpdateTree();
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  TextProcessorManager.UnloadTreeAndSave(SettingsFile.ConfigNode);
  SettingsFile.Free;
  TextProcessorManager.Free;
end;

procedure TMainForm.PopupMenu1Popup(Sender: TObject);
begin
  PopupMenu1.Items[0].Enabled := Assigned(GetSelectedGraphNode());
end;

procedure TMainForm.DeleteMenuItemClick(Sender: TObject);
var
  Node: TTextProcessorNode;
begin
  Node := GetSelectedGraphNodeData;
  if Assigned(Node) then
  begin
    Node.Remove;
    UpdateTree;
  end;
end;

procedure TMainForm.AddMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  TextProcessorNode: TTextProcessorNode;
  List: TList<ITextProcessorInfo>;
  NodeData: TTextProcessorNode;
  NewNode: TTextProcessorNode;
  TextProcessorID: TGUID;
begin
  MenuItem := Sender as TMenuItem;

  List := TList<ITextProcessorInfo>.Create;
  try
    TextProcessorManager.GetAvailableTextProcessors(List);
    TextProcessorID := List[MenuItem.Tag].ID;
  finally
    List.Free;
  end;

  NodeData := GetSelectedGraphNodeData;
  if Assigned(NodeData) then
    TextProcessorNode := NodeData
  else
    TextProcessorNode := TextProcessorManager.TextProcessorTree;

  NewNode := TextProcessorManager.NewTextProcessorNode(TextProcessorID);
  if Assigned(NewNode) then
    TextProcessorNode.InsertTextProcessorNode(NewNode);

  UpdateTree;
end;

procedure TMainForm.AddItemsToTree(TextProcessorNode: TTextProcessorNode;
AParentVisualNode: PVirtualNode = nil);
var
  NewNode: PVirtualNode;
  i: Integer;
begin
  for i := 0 to TextProcessorNode.ChildCount - 1 do
  begin
    NewNode := FilterGraphTree.AddChild(AParentVisualNode,
      TextProcessorNode.Childs[i]);
    AddItemsToTree(TextProcessorNode.Childs[i], NewNode);
  end;
end;

procedure TMainForm.UpdateTree;
begin
  FilterGraphTree.Clear;
  AddItemsToTree(TextProcessorManager.TextProcessorTree);
  FilterGraphTree.FullExpand();
end;

end.
