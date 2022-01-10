program TestParseFile;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  Dynlibs, libxml2;

type

  { TTestParseFile }

  TTestParseFile = class(TCustomApplication)
  protected
    procedure DoRun; override;
    function myParseFile (aFileName: AnsiString): xmlDocPtr;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TTestParseFile }

procedure TTestParseFile.DoRun;
var
  ErrorMsg: String;
  aFilename: String;
  doc: xmlDocPtr;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('hf', 'help filename');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  if HasOption('f', 'filename') then begin
    aFilename := GetOptionValue('f', 'filename');
    Write(aFilename, ': ');
    doc := myParseFile(PChar(aFileName));
    if (doc=nil) then begin
      writeln('File is NOT well-formed');
    end else begin
      writeln('File is well-formed');
      xmlFreeDoc(doc);
    end;
  end;

  // stop program loop
  Terminate;
end;

function TTestParseFile.myParseFile(aFileName: AnsiString): xmlDocPtr;
var
  ctxt: xmlParserCtxtPtr;
begin
  Result := nil;
  xmlFreePascalInitParser();
  ctxt := xmlCreateFileParserCtxt(PAnsiChar(aFileName));
  if (ctxt = nil) then exit;
  xmlParseDocument(ctxt);
  if (ctxt^.wellFormed<>0) then begin
    Result := ctxt^.myDoc;
  end else begin
    xmlFreeDoc(ctxt^.myDoc);
    ctxt^.myDoc := nil;
  end;
  xmlFreeParserCtxt(ctxt);
end;

constructor TTestParseFile.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TTestParseFile.Destroy;
begin
  inherited Destroy;
end;

procedure TTestParseFile.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -f: File to be parsed and checked for well formed');
  writeln('Usage: ', ExeName, ' -h: This help');
end;

var
  Application: TTestParseFile;
begin
  Application:=TTestParseFile.Create(nil);
  Application.Title:='Test parse file';
  Application.Run;
  Application.Free;
end.

