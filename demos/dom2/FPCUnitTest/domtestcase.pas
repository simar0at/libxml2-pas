unit domTestCase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, idom2;

type

  { TDomTestCase }

  TDomTestCase = class(TTestCase)
  private
    class var fCurrendVID: string;
    fVendorID: string;
    fDocumentBuilder: IDomDocumentBuilder;
  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure setVendorID(aVendorID: string);
    function getVendorID: string;
    function getDocumentBuilder: IDomDocumentBuilder;
  end;

implementation

{ TDomTestCase }

constructor TDomTestCase.Create;
begin
  inherited Create;
  fVendorID:=fCurrendVID;
  fDocumentBuilder:=getDocumentBuilderFactory(fVendorID).newDocumentBuilder;;
end;

destructor TDomTestCase.Destroy;
begin
  fDocumentBuilder:=nil;
  inherited Destroy;
end;

class procedure TDomTestCase.setVendorID(aVendorID: string);
begin
  fCurrendVID:=aVendorID;
end;

function TDomTestCase.getVendorID: string;
begin
  Result:=fVendorID;
end;

function TDomTestCase.getDocumentBuilder: IDomDocumentBuilder;
begin
  Result:=fDocumentBuilder;
end;

end.

