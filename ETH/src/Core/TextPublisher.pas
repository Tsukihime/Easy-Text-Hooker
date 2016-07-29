unit TextPublisher;

interface

uses
  PluginAPI_TLB,
  SysUtils,
  System.Generics.Collections;

type
  IPublisher = interface
    ['{73D0451C-194B-48F3-95B0-6E1FE244959E}']
    procedure Subscribe(const ASubscriber: IUnknown);
    procedure Unsubscribe(const ASubscriber: IUnknown);
    procedure UnsubscribeAll;
  end;

  TBasePublisher = class(TInterfacedObject, IPublisher)
  protected
    FSubscribers: TList<IUnknown>;
  public
    procedure Subscribe(const ASubscriber: IUnknown);
    procedure Unsubscribe(const ASubscriber: IUnknown);
    procedure UnsubscribeAll;
    constructor Create;
    destructor Destroy; override;
  end;

  TTextEventsBroadcaster = class(TBasePublisher, ITextEvents)
  private
    procedure OnNewText(const Text: WideString); safecall;
  end;

implementation

{ TBasePublisher }

constructor TBasePublisher.Create;
begin
  FSubscribers := TList<IUnknown>.Create;
end;

destructor TBasePublisher.Destroy;
begin
  FSubscribers.Free;
  inherited;
end;

procedure TBasePublisher.Subscribe(const ASubscriber: IInterface);
begin
  FSubscribers.Add(ASubscriber);
end;

procedure TBasePublisher.Unsubscribe(const ASubscriber: IInterface);
begin
  FSubscribers.Remove(ASubscriber);
end;

procedure TBasePublisher.UnsubscribeAll;
begin
  FSubscribers.Clear;
end;

{ TTextEventsBroadcaster }
procedure TTextEventsBroadcaster.OnNewText(const Text: WideString);
var
  Subscriber: IUnknown;
  events: ITextEvents;
begin
  for Subscriber in FSubscribers do
    if Supports(Subscriber, ITextEvents, events) then
      events.OnNewText(Text);
end;

end.
